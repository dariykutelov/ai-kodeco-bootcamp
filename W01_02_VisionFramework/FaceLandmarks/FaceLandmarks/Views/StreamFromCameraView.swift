//
//  StreamFromCameraView.swift
//  FaceLandmarks
//
//  Created by Dariy Kutelov on 15.10.25.
//

import SwiftUI
import AVFoundation
import Vision

struct StreamFromCameraView: View {
    @StateObject private var coordinator = CameraView.Coordinator()

        var body: some View {
            ZStack {
                CameraView(coordinator: coordinator)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Text("👀 Googly Eyes Camera")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .shadow(radius: 2)
                        .padding(12)
                        .background(.black.opacity(0.4))
                        .cornerRadius(10)
                        .padding()
                    
                    Spacer()
                }
            }
            .onAppear {
                coordinator.startSession()
            }
            .onDisappear {
                coordinator.stopSession()
            }
        }
}



#Preview {
    StreamFromCameraView()
}
