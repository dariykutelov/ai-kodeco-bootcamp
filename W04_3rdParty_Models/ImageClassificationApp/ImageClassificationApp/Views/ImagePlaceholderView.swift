//
//  ImagePlacehoderView.swift
//  ImageClassificationApp
//
//  Created by Dariy Kutelov on 7.11.25.
//

import SwiftUI

struct ImagePlaceholderView: View {
    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                Color.gray.opacity(0.3)
                Image(systemName: "photo")
                    .font(.system(size: 150))
                    .foregroundStyle(.gray)
                    .opacity(0.2)
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .overlay(alignment: .bottom) {
                VStack(spacing: 2) {
                    Text("Select a photo")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Use the image icon in the top right corner")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom)
            }
        }
        .padding(40)
    }
}

#Preview {
    ImagePlaceholderView()
}
