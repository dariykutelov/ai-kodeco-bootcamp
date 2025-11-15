//
//  MessageBubbleView.swift
//  CarHelp
//
//  Created by Dariy Kutelov on 14.11.25.
//

import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    
    private var isUser: Bool { message.role == .user }
    
    var body: some View {
        // MARK: Bubble View
        bubbleContent
            .padding()
            .background(isUser ? Color.blue : Color.gray.opacity(0.1))
            .foregroundColor(isUser ? .white : .primary)
            .cornerRadius(10)
            .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
    }
    
    @ViewBuilder
    private var bubbleContent: some View {
        switch message.content {
        case .text(let text):
            //MARK: Text Message
            textView(for: text)
        case .items(let items):
            //MARK: Message with text and image
            VStack(alignment: isUser ? .trailing : .leading, spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    switch item {
                    case .text(let textContent):
                        textView(for: textContent.text)
                    case .image(let imageContent):
                        imageView(for: imageContent)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func textView(for text: String) -> some View {
        if message.role == .assistant {
            Text(LocalizedStringKey(text))
                .multilineTextAlignment(.leading)
        } else {
            Text(text)
                .multilineTextAlignment(.leading)
        }
    }
    
    @ViewBuilder
    private func imageView(for content: ImageContent) -> some View {
        if let inlineImage = imageFromDataURL(content.imageUrl) {
            //MARK: Inline Base64 Image
            Image(uiImage: inlineImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 240)
                .cornerRadius(8)
        } else if let url = URL(string: content.imageUrl) {
            //MARK: Remote Image URL if model respose includes image URL
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    placeholderImage
                @unknown default:
                    placeholderImage
                }
            }
            .frame(maxWidth: 240)
            .cornerRadius(8)
        } else {
            placeholderImage
        }
    }
    
    //MARK: Placeholder Image View
    private var placeholderImage: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 80)
            .foregroundColor(.gray)
    }
    
    //MARK: Decode Base64 Image from Data URL
    private func imageFromDataURL(_ dataURL: String) -> UIImage? {
        guard let base64Range = dataURL.range(of: "base64,") else { return nil }
        let encoded = String(dataURL[base64Range.upperBound...])
        guard let data = Data(base64Encoded: encoded) else { return nil }
        return UIImage(data: data)
    }
}

#Preview {
    MessageBubbleView(
        message: Message(
            role: .assistant,
            content: "This is a sample message from the assistant."
        )
    )
}
