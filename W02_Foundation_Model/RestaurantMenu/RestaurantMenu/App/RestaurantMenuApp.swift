//
//  RestaurantMenuApp.swift
//  RestaurantMenu
//
//  Created by Dariy Kutelov on 21.10.25.
//

import SwiftUI

@main
struct RestaurantMenuApp: App {
    @State private var menuViewModel = MenuViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(menuViewModel)
        }
    }
}
