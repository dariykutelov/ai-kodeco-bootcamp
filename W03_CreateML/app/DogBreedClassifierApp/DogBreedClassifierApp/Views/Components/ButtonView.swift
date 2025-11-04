//
//  ButtonView.swift
//  DogBreedClassifierApp
//
//  Created by Dariy Kutelov on 29.10.25.
//

import SwiftUI

struct ButtonView: View {
    let iconName: String
    let buttonText: String
    let backgroundColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.body)
            Text(buttonText)
                .font(.body)
        }
        .padding(12)
        .accentColor(.white)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8,
                   style: .continuous))
    }
}

#Preview {
    ButtonView(
        iconName: "camera.fill",
        buttonText: "Camera",
        backgroundColor: .blue
    )
}
