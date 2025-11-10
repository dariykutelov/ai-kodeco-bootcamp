//
//  InputMessageView.swift
//  CarHelp
//
//  Created by Dariy Kutelov on 10.11.25.
//

import SwiftUI

struct InputMessageView: View {
  @Binding var inputText: String
  @Binding var isLoading: Bool
  let sendMessage: () -> Void

    var body: some View {
          HStack {
            TextField("Type your message...", text: $inputText, axis: .vertical)
              .textFieldStyle(RoundedBorderTextFieldStyle())
              .padding()
            
            if isLoading {
              ProgressView()
                .padding()
            }
            
            Button(action: sendMessage) {
              Text("Submit")
            }
            .disabled(inputText.isEmpty || isLoading)
            .padding()
          }
    }
}

#Preview {
    InputMessageView(
        inputText: .constant(""),
        isLoading: .constant(false),
        sendMessage: {}
    )
}
