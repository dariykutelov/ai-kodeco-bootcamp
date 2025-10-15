//
//  HomeView.swift
//  FaceLandmarks
//
//  Created by Dariy Kutelov on 15.10.25.
//

import SwiftUI
import AVFoundation
import PhotosUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    
    @State private var showCameraPicker = false
    
    var body: some View {
        VStack {
            if let image = viewModel.drawFaceLandmarks() {
              Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
            } else {
              Text("No image selected")
            }
            
            VStack {
                Text("Select an image")
                    .font(.title)
                HStack {
                    PhotosPicker(
                        selection: $viewModel.selectedPickerItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Image(systemName: "photo.fill")
                            .font(Font.largeTitle.bold())
                            .padding(8)
                    }
                    
                    Button {
                        switch viewModel.cameraPermissionStatus {
                        case .authorized:
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
                viewModel.detectFaces()
            } label: {
                Text("Draw Landmarks")
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
            Text(permissionMessage)
              .padding()
        }
        .sheet(isPresented: $showCameraPicker) {
          CameraPicker(selectedImage: $viewModel.selectedOrCapturedImage)
        }
    }
    
    private var permissionMessage: String {
      switch viewModel.cameraPermissionStatus {
      case .authorized:
        return "Camera permission granted."
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
    HomeView()
}
