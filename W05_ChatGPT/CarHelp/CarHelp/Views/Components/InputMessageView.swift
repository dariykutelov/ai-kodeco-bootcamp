//
//  InputMessageView.swift
//  CarHelp
//
//  Created by Dariy Kutelov on 10.11.25.
//

import SwiftUI
import PhotosUI

struct InputMessageView: View {
    @Binding var inputText: String
    @Binding var isLoading: Bool
    @Binding var selectedPickerItem: PhotosPickerItem?
    @Binding var selectedImage: UIImage?
    let sendMessage: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            if let image = selectedImage {
                HStack {
                    // MARK: Selected Image Preview
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(8)
                    
                    // MARK: Remove Image Button
                    Button(action: {
                        selectedImage = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 8)
            }
            
            HStack {
                // MARK: Photo Picker
                PhotosPicker(
                    selection: $selectedPickerItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Image(systemName: "photo.fill")
                        .font(.title2.bold())
                        .padding(.leading, 8)
                        .foregroundColor(.primary)
                }
                
                // MARK: Input Text Field
                TextField("Type your message...", text: $inputText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(8)
                
                if isLoading {
                    ProgressView()
                        .padding()
                }
                
                // MARK: Send Button
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2.bold())
                }
                .disabled((inputText.isEmpty && selectedImage == nil) || isLoading)
                .padding(.trailing, 8)
            }
        }
    }
}

#Preview {
    InputMessageView(
        inputText: .constant(""),
        isLoading: .constant(false),
        selectedPickerItem: .constant(nil),
        selectedImage: .constant(nil),
        sendMessage: {}
    )
}
