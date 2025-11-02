//
//  CharacteristicCard.swift
//  DogBreedClassifierApp
//
//  Created by Dariy Kutelov on 2.11.25.
//

import SwiftUI

struct CharacteristicCard: View {
    let characteristic: Breed.Characteristic
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: characteristic.icon)
                    .foregroundStyle(.blue)
                    .font(.title3)
                Text(characteristic.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Text(characteristic.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
        }
    }
}

#Preview {
    CharacteristicCard(
        characteristic: Breed.Characteristic(
            title: "Barking",
            description: "More than average barks",
            icon: "speaker.wave.3"
        )
    )
    .padding()
}

