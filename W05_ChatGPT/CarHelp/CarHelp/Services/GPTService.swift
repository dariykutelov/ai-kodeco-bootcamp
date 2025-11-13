//
//  GPTService.swift
//  CarHelp
//
//  Created by Dariy Kutelov on 10.11.25.
//

import Foundation

class GPTService {
    
    // MARK: - Properties
    
    var model: GPTModelVersion
    private let apiKey: String
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let urlSession: URLSession
    private let endpoint: URL
    
    
    // MARK: - Initializer
    
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
    
    
    // MARK: - Methods: Stream Chats
    
    // TODO: - Add web support
    func streamChat(context: [Message], messages: [Message]) -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let chatRequest = GPTChatRequest(
                        model: model,
                        messages: context + messages,
                        stream: true,
                        tools: [GPTChatRequest.Tool(type: "web_search")]
                    )
                    let body = try encoder.encode(chatRequest)
                    let request = requestFor(url: endpoint, httpMethod: "POST", httpBody: body)
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw GPTClientError.networkError(message: "URLResponse is not an HTTPURLResponse")
                    }
                    
                    if httpResponse.statusCode != 200 {
                        throw try await handleStreamResponseError(statusCode: httpResponse.statusCode,
                                                                  bytes: bytes)
                    }
                    
                    var botMessage = ""
                    try await handleResponseStreamData(bytes: bytes,
                                                       continuation: continuation,
                                                       botMessage: &botMessage)
                    
                    continuation.finish()
                } catch {
                    print("stream error: \(error)")
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private func handleResponseStreamData(bytes: URLSession.AsyncBytes,
                                          continuation: AsyncThrowingStream<String, Error>.Continuation,
                                          botMessage: inout String) async throws {
        
        for try await line in bytes.lines {
            guard line.hasPrefix("data:") else { continue }
            
            let payload = line.dropFirst(5)
            let trimmed = payload.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed == "[DONE]" { break }
            
            guard let chunkData = trimmed.data(using: .utf8) else { continue }
    
            let event: GPTChatStreamResponse
            
            do {
                event = try decoder.decode(GPTChatStreamResponse.self, from: chunkData)
            } catch {
                print("stream decode error: \(error.localizedDescription)")
                continue
            }
            
            switch event.type {
            case "response.output_text.delta":
                if let delta = event.delta {
                    botMessage += delta
                    continuation.yield(botMessage)
                }
            case "response.completed":
                continuation.finish()
                return
            case "response.error":
                let message = event.error?.error.message ?? "Unknown streaming error"
                throw GPTClientError.networkError(message: message)
            default:
                continue
            }
        }
    }
    
    
    // MARK: - Methods: Summarize Conversation
    
    func summarizeConversation(context: [Message],
                               oldMessages: [Message]) async throws -> GPTChatResponse {
        
        do {
            let chatRequest = GPTChatRequest(model: model,
                                             messages: context + oldMessages,
                                             stream: false,
                                             tools: [])
            let data = try encoder.encode(chatRequest)
            let request = requestFor(url: endpoint, httpMethod: "POST", httpBody: data)
            let (responseData, urlResponse) = try await urlSession.data(for: request)
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                throw GPTClientError.networkError(message: "URLResponse is not an HTTPURLResponse")
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorResponse = try? decoder.decode(GPTErrorResponse.self, from: responseData)
                let bodyString = String(data: responseData, encoding: .utf8)
                throw GPTClientError.errorResponse(statusCode: httpResponse.statusCode,
                                                   error: errorResponse, body: bodyString)
            }
            
            let chatResponse = try decoder.decode(GPTChatResponse.self, from: responseData)
            return chatResponse
        } catch {
            throw GPTClientError.networkError(
                message: "⚠️ Failed to summarize: \(error.localizedDescription)",error: error)
        }
    }
    
    
    // MARK: - Helper Methods
    
    private func requestFor(url: URL, httpMethod: String, httpBody: Data?) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "POST"
        request.httpBody = httpBody
        return request
    }
    
    private func handleStreamResponseError(statusCode: Int, bytes: URLSession.AsyncBytes) async throws -> Error {
        var errorData = Data()
        for try await line in bytes.lines {
            guard line.hasPrefix("data:") else { continue }
            let payload = line.dropFirst(5)
            let trimmed = payload.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed == "[DONE]" { continue }
            if let chunk = trimmed.data(using: .utf8) {
                errorData.append(chunk)
            }
        }
        let errorResponse = try? decoder.decode(GPTErrorResponse.self, from: errorData)
        let bodyString = errorData.isEmpty ? nil : String(data: errorData, encoding: .utf8)
        return GPTClientError.errorResponse(statusCode: statusCode, error: errorResponse, body: bodyString)
    }
}
