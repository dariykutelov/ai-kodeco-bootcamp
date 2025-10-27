//
//  ModelUnavailableView.swift
//  RestaurantMenu
//
//  Created by Dariy Kutelov on 24.10.25.
//

import SwiftUI
import FoundationModels

struct ModelUnavailableView: View {
    var reason: SystemLanguageModel.Availability.UnavailableReason
    
    
    var body: some View {
        VStack {
            Image(systemName: "apple.intelligence")
                .font(.largeTitle)
                .padding()
            
            switch reason {
            case .deviceNotEligible:
                Text("Apple Intelligence is not available on this device.")
            case .appleIntelligenceNotEnabled:
                Text("Apple Intelligence is available, but not enabled on this device.")
            case .modelNotReady:
                Text("The model isn't ready. This is usually because it is still downloading.")
            @unknown default:
                Text("An unknown error prevents Apple Intelligence from working.")
            }
        }
        .padding()
    }
}

#Preview {
    ModelUnavailableView(reason: .appleIntelligenceNotEnabled)
}
