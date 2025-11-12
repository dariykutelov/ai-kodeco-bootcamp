//
//  ContentView.swift
//  CarHelp
//
//  Created by Dariy Kutelov on 10.11.25.
//

import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewViewModel(model: .gpt41mini)
    
    var body: some View {
        NavigationView {
            VStack {
                // TODO: - Scroll with the text generation
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(viewModel.messages, id: \.self) { message in
                            if (message.role == .user) {
                                Text(message.content)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            } else {
                                Text(message.content)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding()
                }
                InputMessageView(inputText: $viewModel.userInput, isLoading: $viewModel.isLoading, sendMessage: viewModel.sendMessage)
            }
            .navigationTitle("Help Desk Chat")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("New") {
                viewModel.messages = viewModel.messages.count > 0 ? [viewModel.messages[0]] : []
            }.disabled(viewModel.messages.count < 2))
        }
    }
}

#Preview {
    ChatView()
}
