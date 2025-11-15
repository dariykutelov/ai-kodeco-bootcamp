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
                // MARK: Messages List View
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.messages, id: \.self) { message in
                            MessageBubbleView(message: message)
                        }
                    }
                    .padding()
                }
                
                // MARK: Input Message View
                InputMessageView(inputText: $viewModel.userInput,
                                 isLoading: $viewModel.isLoading,
                                 selectedPickerItem: $viewModel.selectedPickerItem,
                                 selectedImage: $viewModel.selectedImage,
                                 sendMessage: viewModel.sendMessage)
            }
            .navigationTitle("Help Desk Chat")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("New") {
                    viewModel.messages = viewModel.messages.count > 0 ? [viewModel.messages[0]] : []
                }.disabled(viewModel.messages.count < 2)
            )
        }
    }
}




#Preview {
    ChatView()
}
