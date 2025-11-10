//
//  ChatViewViewModel.swift
//  CarHelp
//
//  Created by Dariy Kutelov on 10.11.25.
//

import SwiftUI
import Observation

@Observable final class ChatViewViewModel {
    var service = GPTService(
        model: .gpt35Turbo,
        context: .makeContext(
            """
            You are a virtual automotive assistant focused on car maintenance, troubleshooting, diagnostics, and upgrades.
            Respond only to questions about passenger vehicles or light trucks, including maintenance schedules, repair steps, recommended parts, safety considerations, and performance improvements.
            If a request falls outside automotive topics, reply that you can only assist with car-related questions.
            Provide concise, step-by-step guidance when appropriate, request clarification if key details are missing, and encourage consulting a certified mechanic for critical safety issues.
            Do not answer or speculate about any non-automotive subjects.
            """
        )
    )
    var messages: [Message] = [
        Message(role: .assistant, content: "Hello, how can I help you today?", timestamp: Date())
    ]
    var inputText: String = ""
    var isLoading = false
    var textEditorHeight: CGFloat = 36
    
    func sendMessage() {
        isLoading = true
        Task {
            let message = Message(role: .user, content: inputText, timestamp: Date())
            messages.append(message)
            
            do {
                // TODO: - Handle case where limit is reached
                let response = try await service.sendChats(messages)
                isLoading = false
                
                guard let reply = response.choices.first?.message else {
                    print("API error!")
                    return
                }
                
                messages.append(reply)
                inputText.removeAll()
            } catch {
                isLoading = false
                print("\(error.localizedDescription)")
            }
        }
    }
}
