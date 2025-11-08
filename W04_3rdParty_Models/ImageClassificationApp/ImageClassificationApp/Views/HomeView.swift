//
//  ContentView.swift
//  ImageClassificationApp
//
//  Created by Dariy Kutelov on 7.11.25.
//

import SwiftUI
import PhotosUI

struct HomeView: View {
    @State private var viewModel = HomeViewViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                //MARK: Selected Image
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .scaledToFit()
                    
                    //MARK: Model Picker
                    Picker("Model", selection: $viewModel.selectedModel) {
                        Text("YOLO").lineLimit(2).multilineTextAlignment(.center).tag(SelectedModel.yolov8x_cls_converted)
                        Text("YOLO8").lineLimit(2).multilineTextAlignment(.center).tag(SelectedModel.yolov8x_cls_int8)
                        Text("ResNet").lineLimit(2).multilineTextAlignment(.center).tag(SelectedModel.ResNet50)
                        Text("ResNet8").lineLimit(2).multilineTextAlignment(.center).tag(SelectedModel.ResNet50_int8)
                        Text("MobileNetV2").lineLimit(2).multilineTextAlignment(.center).tag(SelectedModel.MobileNetV2)
                    }
                    .pickerStyle(.segmented)
                    .frame(height: 72)
                    .padding(.vertical)
                    
                    if viewModel.isClassifying {
                        //MARK: Loading Spinner
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if let result = viewModel.classificationResult {
                        //MARK: Classification Results
                        VStack(alignment: .center, spacing: 4) {
                            Text(result.label)
                                .font(.headline)
                            Text(String(format: "%.2f%%", result.probability * 100))
                                .font(.subheadline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.secondary.opacity(0.3))
                        )
                    }
                } else {
                    //MARK: Image Placeholder
                    ImagePlaceholderView()
                }
                
                if let message = viewModel.errorMessage {
                    //MARK: Error Message
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Image Classifier")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    //MARK: Photo picker button
                    Button {
                        viewModel.reset()
                    } label: {
                        PhotosPicker(
                            selection: $viewModel.selectedPickerItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Image(systemName: "photo.fill")
                                .font(.title3.bold())
                        }
                    }
                }
            }
        }
        .task(id: viewModel.selectedImage) {
            viewModel.classifyImage()
        }
        .task(id: viewModel.selectedModel) {
            viewModel.classifyImage()
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
