//
//  GPTService.swift
//  CarHelp
//
//  Created by Dariy Kutelov on 10.11.25.
//

import Foundation

class GPTService {
    var model: GPTModelVersion
    private let apiKey: String
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let urlSession: URLSession
    private let endpoint: URL
    
    init(apiKey: String = Secrets.openAIKey,
         model: GPTModelVersion,
         context: [Message] = [],
         urlSession: URLSession = .shared) {
        self.apiKey = apiKey
        self.model = model
        self.urlSession = urlSession
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        self.decoder = decoder     
        self.encoder = JSONEncoder()
        self.endpoint = URL(string: "https://api.openai.com/v1/responses")!
    }
    
    private func requestFor(url: URL, httpMethod: String, httpBody: Data?) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "POST"
        request.httpBody = httpBody
        return request
    }
    
    
    // TODO: - Add web support
    // TODO: - Refactor error handling and clean up the code, split in private helper methods
    func streamChats(context: [Message], messages: [Message]) -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let chatRequest = GPTChatRequest(model: model, messages: context + messages, stream: true)
                    let body = try encoder.encode(chatRequest)
                    let request = requestFor(url: endpoint, httpMethod: "POST", httpBody: body)
                    
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw GPTClientError.networkError(message: "URLResponse is not an HTTPURLResponse")
                    }
                    
                    guard httpResponse.statusCode == 200 else {
                        var collected = Data()
                        var decodedError: GPTErrorResponse? = nil
                        do {
                            for try await line in bytes.lines {
                                if line.hasPrefix("data:") {
                                    let jsonLine = line.dropFirst(5)
                                    if jsonLine.trimmingCharacters(in: .whitespacesAndNewlines) == "[DONE]" { continue }
                                    if let d = String(jsonLine).data(using: .utf8) {
                                        if decodedError == nil {
                                            decodedError = try? decoder.decode(GPTErrorResponse.self, from: d)
                                        }
                                        collected.append(d)
                                    }
                                } else {
                                    if let d = line.data(using: .utf8) {
                                        collected.append(d)
                                    }
                                }
                            }
                        } catch {
                            print("Failed to collect error body from stream: \(error)")
                        }
                        
                        let bodyString = (collected.isEmpty ? nil : String(data: collected, encoding: .utf8))
                        if decodedError == nil, let bodyString = bodyString {
                            print("stream error body: \(bodyString)")
                        }
                        
                        throw GPTClientError.errorResponse(statusCode: httpResponse.statusCode, error: decodedError, body: bodyString)
                    }
                    
                    var botMessage = ""
                    
                    for try await line in bytes.lines {
                        guard line.hasPrefix("data:") else { continue }
                         let payload = line.dropFirst(5)
                        let trimmed = payload.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed == "[DONE]" { break }
                        guard let chunkData = trimmed.data(using: .utf8),
                              // TODO: - Use Codable struct instead of [String: Any]
                                let json = try? JSONSerialization.jsonObject(with: chunkData) as? [String: Any],
                              let type = json["type"] as? String else {
                            continue
                        }
                        
                        switch type {
                        case "response.output_text.delta":
                            if let delta = json["delta"] as? String {
                                botMessage += delta
                                continuation.yield(botMessage)
                            }
                        case "response.completed":
                            continuation.finish()
                            return
                        case "response.error":
                            if let errorDict = json["error"] as? [String: Any],
                               let message = errorDict["message"] as? String {
                                throw GPTClientError.networkError(message: message)
                            } else {
                                throw GPTClientError.networkError(message: "Unknown streaming error")
                            }
                        default:
                            continue
                        }
                    }
                    
                    continuation.finish()
                } catch {
                    print("stream error: \(error)")
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    
    func summarizeConversation(context: [Message], oldMessages: [Message]) async throws -> GPTChatResponse {
        do {
            let chatRequest = GPTChatRequest(model: model, messages: context + oldMessages, stream: false)
            let data = try encoder.encode(chatRequest)

            let request = requestFor(url: endpoint, httpMethod: "POST", httpBody: data)
       
            let (responseData, urlResponse) = try await urlSession.data(for: request)
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                throw GPTClientError.networkError(message: "URLResponse is not an HTTPURLResponse")
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorResponse = try? decoder.decode(GPTErrorResponse.self, from: responseData)
                let bodyString = String(data: responseData, encoding: .utf8)
                throw GPTClientError.errorResponse(statusCode: httpResponse.statusCode, error: errorResponse, body: bodyString)
            }
            
            let chatResponse = try decoder.decode(GPTChatResponse.self, from: responseData)
            return chatResponse
        } catch {
            throw GPTClientError.networkError(message: "⚠️ Failed to summarize: \(error.localizedDescription)", error: error)
        }
    }
}
