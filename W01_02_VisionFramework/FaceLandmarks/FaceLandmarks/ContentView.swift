//
//  ContentView.swift
//  FaceLandmarks
//
//  Created by Dariy Kutelov on 15.10.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            FunnyFaceView()
                .tabItem {
                    Label("Funny Face", systemImage: "photo.on.rectangle")
                }
            
            StreamFromCameraView()
                .tabItem {
                    Label("Camera", systemImage: "video.fill")
                }
            
            SunglassesView()
                .tabItem {
                    Label("Sun Glasses", systemImage: "sunglasses.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
