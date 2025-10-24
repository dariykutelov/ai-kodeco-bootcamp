//
//  RestaurantMenuApp.swift
//  RestaurantMenu
//
//  Created by Dariy Kutelov on 21.10.25.
//

import SwiftUI
import FoundationModels

@main
struct RestaurantMenuApp: App {
    private let model = SystemLanguageModel.default
    
    var body: some Scene {
        WindowGroup {
            switch model.availability {
            case .available:
                HomeView()
            case .unavailable(let reason):
                ModelUnavailableView(reason: reason)
            }
        }
    }
}
