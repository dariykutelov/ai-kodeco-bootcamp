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
    @State private var viewModel = FunnyFaceViewModel()
    
    @State private var showCameraPicker = false
    
    var body: some View {
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
              Text("No image selected")
            }
            
            Spacer()
            
            VStack {
                HStack {
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
                                .padding(8)
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
                            .padding(8)
                    }
                }
            }
            
            Button {
                viewModel.detectFace()
            } label: {
                Text("Funny face!")
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
            Text(permissionMessage)
              .padding()
            
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
    }
    
    private var permissionMessage: String {
      switch viewModel.cameraPermissionStatus {
      case .authorized:
        return ""
      case .denied, .restricted:
        return "Camera permission denied. Please go to Settings to enable it."
      case .notDetermined:
        return "Camera permission not yet requested. Tap the button to request it."
      @unknown default:
        return ""
      }
    }
}

#Preview {
    FunnyFaceView()
}
