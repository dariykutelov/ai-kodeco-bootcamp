//
//  ChatViewViewModel.swift
//  CarHelp
//
//  Created by Dariy Kutelov on 10.11.25.
//

import SwiftUI
import Observation
import PhotosUI

@MainActor
@Observable final class ChatViewViewModel {
    
    // MARK: - Properties
    
    let model: GPTModelVersion
    var service: GPTService
    var messages: [Message] = [
        Message(role: .assistant, content: "Hello, how can I help you today?")
    ]
    var userInput: String = ""
    var selectedImage: UIImage? {
        didSet {
            if let image = selectedImage {
                selectedImageDataURL = prepareImageDataURL(from: image)
            } else {
                selectedImageDataURL = nil
            }
        }
    }
    private var selectedImageDataURL: String?
    var selectedPickerItem: PhotosPickerItem? {
        didSet {
            if let item = selectedPickerItem {
                loadImage(from: item)
            }
        }
    }
    var isLoading = false
    var errorMessage: String? = nil
    
    
    // MARK: - Initializer
    
    init(model: GPTModelVersion = .gpt41mini) {
        self.model = model
        self.service = GPTService(model: model)
    }
    
    
    // MARK: - Methods: Send Message
    
    func sendMessage() {
        guard !userInput.isEmpty || selectedImageDataURL != nil else { return }
        
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
        
        let hasImageAttachment = selectedImageDataURL != nil
        let userMessage: Message
        if let imageDataURL = selectedImageDataURL {
            userMessage = Message.withImage(
                role: .user,
                text: input.isEmpty ? nil : input,
                imageUrl: imageDataURL
            )
        } else {
            userMessage = Message(role: .user, content: input)
        }
        messages.append(userMessage)
        userInput = ""
        selectedImage = nil
        selectedPickerItem = nil
        
        var requestMessages = messages
        if hasImageAttachment {
            requestMessages.append(
                Message(
                    role: .system,
                    content: "The previous user message includes an attached vehicle photo. Analyze the image for visible car damages or issues and include those observations in your response."
                )
            )
        }
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
        let contextWords = ContextType.initial.chatContext.reduce(0) { $0 + wordCount(for: $1.content.textValue) }
        let messageWords = messages.reduce(0) { $0 + wordCount(for: $1.content.textValue) }
        let inputWords = wordCount(for: userInput)
        let totalWords = contextWords + messageWords + inputWords
        return Double(totalWords) * 0.75
    }
    
    private func wordCount(for text: String) -> Int {
        text.split { $0.isWhitespace || $0.isNewline }.count
    }
    
    
    //MARK: - Load Image from PhotosPickerItem
    
    private func loadImage(from item: PhotosPickerItem) {
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data = data, let uiImage = UIImage(data: data) {
                        self.selectedImage = uiImage
                        self.errorMessage = nil
                    } else {
                        self.selectedImage = nil
                        self.errorMessage = "Unable to decode selected image."
                    }
                case .failure(let error):
                    self.selectedImage = nil
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func prepareImageDataURL(from image: UIImage) -> String? {
        let maxDimension: CGFloat = 512
        let resizedImage = resizeImage(image, maxDimension: maxDimension)
        guard let jpegData = resizedImage.jpegData(compressionQuality: 0.7) else {
            return nil
        }
        let base64 = jpegData.base64EncodedString()
        return "data:image/jpeg;base64,\(base64)"
    }
    
    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let aspect = min(maxDimension / max(size.width, 1), maxDimension / max(size.height, 1))
        if aspect >= 1 { return image }
        let newSize = CGSize(width: size.width * aspect, height: size.height * aspect)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? image
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
