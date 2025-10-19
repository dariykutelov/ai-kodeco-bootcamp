//
//  HomeView.swift
//  FaceLandmarks
//
//  Created by Dariy Kutelov on 15.10.25.
//

import SwiftUI
import AVFoundation
import PhotosUI

struct SunglassesView: View {
    @State private var viewModel = ImageViewModel()
    
    @State private var showCameraPicker = false
    @State private var selectedSunglassesIndex: Int? = nil
    
    private let sunglassesImages = (1...10).map { "sunglasses-\($0)" }
    private var selectedSunglassesImageName: String? {
        return selectedSunglassesIndex != nil ? sunglassesImages[selectedSunglassesIndex!] : nil
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<sunglassesImages.count, id: \.self) { index in
                            Button {
                                selectedSunglassesIndex = index
                            } label: {
                                Image(sunglassesImages[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedSunglassesIndex == index ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedSunglassesIndex == index ? Color.indigo : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                Text("Choose Your Favourite Sunglasses")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.secondaryLabel))
            }
            
            VStack {
                if let selectedSunglassesImageName = selectedSunglassesImageName,
                   let image = viewModel.selectedOrCapturedImage?
                    .addSunglassesOverlay(landmarks: viewModel.faceLandmarks,
                                          boundingBox: viewModel.faceBoundingBox,
                                          sunglassesImage: UIImage(named: selectedSunglassesImageName)
                    ) {
                    Image(uiImage: image)
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .scaledToFit()
                        .padding(.horizontal, 16)
                } else if let image = viewModel.selectedOrCapturedImage {
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
                    }
                    .padding()
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
            .onChange(of: viewModel.selectedOrCapturedImage) { _, newImage in
                if newImage != nil {
                    viewModel.detectFace()
                }
            }
            .navigationTitle("Try Sunglasses")
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
    SunglassesView()
}
