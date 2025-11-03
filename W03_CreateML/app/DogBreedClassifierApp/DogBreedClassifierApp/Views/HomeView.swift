//
//  HomeView.swift
//  DogBreedClassifierApp
//
//  Created by Dariy Kutelov on 29.10.25.
//

import SwiftUI
import PhotosUI

struct HomeView: View {
    @State private var viewModel = HomeViewViewModel()
    @State private var showCameraPicker = false
    @State private var showClassificationResult = false
    @State private var shouldOpenCameraAfterPermission = false
    @State private var pendingClassificationResult = false
    
    var body: some View {
        NavigationStack {
            VStack {
                //MARK: Selected Image
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .scaledToFit()
                        .padding(.horizontal, 16)
                } else {
                    ImagePlaceholderView()
                }
                
                Spacer()
                
                // MARK: Error Message Text
                if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 30) {
                        HStack {
                            Text(errorMessage)
                                .font(.body)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .foregroundStyle(.white)
                                .background(.red)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous), )
                        }
                        .padding()
                    }
                }
                
                
                HStack {
                    // MARK: Camera Button
                    Button {
                        print("Camera button tapped. Permission status: \(viewModel.cameraPermissionStatus.rawValue)")
                        switch viewModel.cameraPermissionStatus {
                        case .authorized:
                            viewModel.reset()
                            showCameraPicker = true
                        case .notDetermined:
                            shouldOpenCameraAfterPermission = true
                            viewModel.requestCameraPermissions()
                        default:
                            print("Camera permission denied/restricted")
                            break
                        }
                    } label: {
                        ButtonView(iconName: "camera.fill",
                                   buttonText: "Camera",
                                   backgroundColor: .blue)
                    }
                    
                    // MARK:  Photo Picker Button
                    Button {
                        viewModel.reset()
                    } label: {
                        PhotosPicker(
                            selection: $viewModel.selectedPickerItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            ButtonView(iconName: "photo.fill",
                                       buttonText: "Photo Picker",
                                       backgroundColor: .green)
                        }
                    }
                }
                
            }
            .navigationTitle("What's This Breed?")
            .onAppear {
                viewModel.checkCameraPermissions()
            }
            .onChange(of: viewModel.selectedImage) { oldValue, newValue in
                if viewModel.selectedImage != nil {
                    showClassificationResult = false
                    viewModel.classifyImage()
                }
            }
            .onChange(of: viewModel.accuracy) { oldValue, newValue in
                if viewModel.dogBreed != .unknown && newValue != nil {
                    if showCameraPicker {
                        pendingClassificationResult = true
                    } else {
                        showClassificationResult = true
                    }
                }
            }
            .onChange(of: viewModel.cameraPermissionStatus) { oldValue, newValue in
                if newValue == .authorized && shouldOpenCameraAfterPermission {
                    shouldOpenCameraAfterPermission = false
                    viewModel.reset()
                    showCameraPicker = true
                }
            }
            .onChange(of: showCameraPicker) { oldValue, newValue in
                if !newValue && pendingClassificationResult {
                    pendingClassificationResult = false
                    Task {
                        try? await Task.sleep(nanoseconds: 300_000_000)
                        await MainActor.run {
                            showClassificationResult = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showCameraPicker) {
                CameraPicker(selectedImage: $viewModel.selectedImage)
            }
            .sheet(isPresented: $showClassificationResult) {
                if let accuracy = viewModel.accuracy {
                    ClassificationResultView(
                        breed: viewModel.dogBreed,
                        accuracy: accuracy,
                        userImage: viewModel.selectedImage,
                    )
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
