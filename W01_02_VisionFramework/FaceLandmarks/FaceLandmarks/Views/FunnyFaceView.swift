//
//  HomeView.swift
//  FaceLandmarks
//
//  Created by Dariy Kutelov on 15.10.25.
//

import SwiftUI
import AVFoundation
import PhotosUI

struct FunnyFaceView: View {
    @State private var viewModel = ImageViewModel()
    
    @State private var showCameraPicker = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let image = viewModel.selectedOrCapturedImage?
                    .drawGooglyEyes(landmarks: viewModel.faceLandmarks,
                                    boundingBox: viewModel.faceBoundingBox) {
                    Image(uiImage: image)
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .scaledToFit()
                        .padding(.horizontal, 16)
                } else {
                    VStack(alignment: .center) {
                        Text("Select an Image")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("No image selected")
                            .font(.body)
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 400)
                }
                
                Spacer()
                
                VStack {
                    HStack(spacing: 4) {
                        Spacer()
                        
                        Button {
                            viewModel.reset()
                        } label: {
                            PhotosPicker(
                                selection: $viewModel.selectedPickerItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                Image(systemName: "photo.fill")
                                    .font(Font.largeTitle.bold())
                                    .accentColor(.indigo)
                            }
                        }
                        
                        Button {
                            switch viewModel.cameraPermissionStatus {
                            case .authorized:
                                viewModel.reset()
                                showCameraPicker = true
                            case .notDetermined:
                                viewModel.requestCameraPermissions()
                            default:
                                break
                            }
                        } label: {
                            Image(systemName: "camera.fill")
                                .font(Font.largeTitle.bold())
                                .accentColor(.indigo)
                        }
                        
                        Button {
                            viewModel.reset()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(Font.largeTitle.bold())
                                .accentColor(.indigo)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    
                    Button {
                        viewModel.detectFace()
                    } label: {
                        Text("Funny face!")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(12)
                    }
                    .buttonStyle(.borderedProminent)
                    .accentColor(.orange)
                    .disabled(viewModel.selectedOrCapturedImage == nil)
                    .padding(.bottom)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
            .sheet(isPresented: $showCameraPicker) {
                CameraPicker(selectedImage: $viewModel.selectedOrCapturedImage)
            }
            .navigationTitle("Googly Eyes")
        }
    }
}

#Preview {
    FunnyFaceView()
}
