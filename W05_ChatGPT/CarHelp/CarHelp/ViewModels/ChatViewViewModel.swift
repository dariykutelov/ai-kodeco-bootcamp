//
//  ChatViewViewModel.swift
//  CarHelp
//
//  Created by Dariy Kutelov on 10.11.25.
//

import SwiftUI
import Observation

@MainActor
@Observable final class ChatViewViewModel {
    
    // MARK: - Properties
    
    let model: GPTModelVersion
    var service: GPTService
    var messages: [Message] = [
        Message(role: .assistant, content: "Hello, how can I help you today?")
    ]
    var userInput: String = "I have a Lexus NX300, 2014 model. The check engine light is on. What should I do?"
    var isLoading = false
    
    
    // MARK: - Initializer
    
    init(model: GPTModelVersion = .gpt41mini) {
        self.model = model
        self.service = GPTService(model: model)
    }
    
    
    // MARK: - Methods: Send Message
    
    func sendMessage() {
        guard !userInput.isEmpty else { return }
        
        let input = userInput
        
        Task { [weak self] in
            await self?.handleSendMessage(input: input)
        }
    }
    
    private func handleSendMessage(input: String) async {
        isLoading = true
        
        let shouldSummarize = estimatedContextTokenCount() > Double(model.contextTresouldLimit)
        
        if shouldSummarize {
            await summarizeChatHistory()
        }
        
        let userMessage = Message(role: .user, content: input)
        messages.append(userMessage)
        userInput = ""
        
        let requestMessages = messages
        messages.append(Message(role: .assistant, content: ""))
        let assistantIndex = messages.count - 1
        let context: [Message] = ContextType.initial.chatContext
        let stream = service.streamChat(context: context, messages: requestMessages)
        
        do {
            for try await partial in stream {
                messages[assistantIndex] = Message(role: .assistant, content: partial)
            }
            
            isLoading = false
        } catch {
            messages[assistantIndex] = Message(role: .assistant, content: "An error occurred. Please try again.")
            isLoading = false
        }
    }
    
    
    // MARK: - Methods: Summarize Chat History
    
    private func summarizeChatHistory() async {
        let context: [Message] = ContextType.summarize.chatContext
        let existingMessages = messages
        
        do {
            let response = try await service.summarizeConversation(context: context, oldMessages: existingMessages)
            guard let summaryText = response.output.first?.content.compactMap({ $0.text }).joined(), !summaryText.isEmpty else {
                isLoading = false
                print("API error!")
                return
            }
            messages = [Message(role: .system, content: summaryText)]
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Helper Methods
    
    private func estimatedContextTokenCount() -> Double {
        let contextWords = ContextType.initial.chatContext.reduce(0) { $0 + wordCount(for: $1.content) }
        let messageWords = messages.reduce(0) { $0 + wordCount(for: $1.content) }
        let inputWords = wordCount(for: userInput)
        let totalWords = contextWords + messageWords + inputWords
        return Double(totalWords) * 0.75
    }
    
    private func wordCount(for text: String) -> Int {
        text.split { $0.isWhitespace || $0.isNewline }.count
    }
}


enum ContextType {
    case initial
    case summarize
    
    var chatContext: [Message] {
        switch self {
        case .initial:
            return .makeContext(
                """
                You are a virtual automotive assistant focused on car maintenance, troubleshooting, diagnostics, and upgrades.
                Respond only to questions about passenger vehicles or light trucks, including maintenance schedules, repair steps, recommended parts, safety considerations, and performance improvements.
                If a request falls outside automotive topics, reply that you can only assist with car-related questions.
                Provide concise, step-by-step guidance when appropriate, request clarification if key details are missing, and encourage consulting a certified mechanic for critical safety issues.
                Do not answer or speculate about any non-automotive subjects.
                """
            )
        case .summarize:
            return .makeContext(
                """
                Summarize the following conversation between a user and an automotive assistant into key points, focusing
                on car maintenance, troubleshooting, diagnostics, and upgrades. Provide a concise summary that captures the main topics discussed.
                Conversation:
                """
            )
        }
    }
    
}
