//
//  RestaurantType.swift
//  RestaurantMenu
//
//  Created by Dariy Kutelov on 21.10.25.
//

import Foundation
import FoundationModels

@Generable(description: "Restaurant type for a restaurant menu. The type has predefined values - Fine dining, Diner, Casual dining, Fast food, Buffet, Deli and Pub.")
enum RestaurantType: String, CaseIterable {
    case fineDining = "Fine dining"
    case diner = "Diner"
    case casualDining = "Casual dining"
    case fastFood = "Fast food"
    case buffet = "Buffet"
    case deli = "Deli"
    case pub = "Pub"
}
