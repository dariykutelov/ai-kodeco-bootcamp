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
                
                if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 30) {
                        // MARK: Error Message Text
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
                            print("Camera authorized - resetting and showing picker")
                            viewModel.reset()
                            showCameraPicker = true
                        case .notDetermined:
                            print("Camera permission not determined - requesting")
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
                print("HomeView - onAppear - checking camera permissions")
                viewModel.checkCameraPermissions()
            }
            .onChange(of: viewModel.selectedImage) { oldValue, newValue in
                print("selectedImage changed - old: \(oldValue != nil), new: \(newValue != nil)")
                if viewModel.selectedImage != nil {
                    print("selectedImage is not nil - resetting modal and calling classifyImage()")
                    showClassificationResult = false
                    viewModel.classifyImage()
                }
            }
            .onChange(of: viewModel.accuracy) { oldValue, newValue in
                print("accuracy changed - old: \(oldValue ?? -1), new: \(newValue ?? -1), breed: \(viewModel.dogBreed)")
                if viewModel.dogBreed != .unknown && newValue != nil {
                    print("Showing classification result modal")
                    showClassificationResult = true
                }
            }
            .onChange(of: viewModel.cameraPermissionStatus) { oldValue, newValue in
                print("Camera permission status changed: \(oldValue.rawValue) -> \(newValue.rawValue)")
                if newValue == .authorized && shouldOpenCameraAfterPermission {
                    print("Camera authorized after request - opening camera")
                    shouldOpenCameraAfterPermission = false
                    viewModel.reset()
                    showCameraPicker = true
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
