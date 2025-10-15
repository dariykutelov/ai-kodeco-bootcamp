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
          HomeView()
            .tabItem {
              Label("Face Effects", systemImage: "photo.on.rectangle")
            }
        }
    }
}

#Preview {
    ContentView()
}
