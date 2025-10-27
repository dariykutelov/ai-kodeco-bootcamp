//
//  RestaurantMenu.swift
//  RestaurantMenu
//
//  Created by Dariy Kutelov on 21.10.25.
//

import Foundation
import FoundationModels

@Generable(description: "A single dish for a restaurant menu.")
struct MenuItem: Identifiable {
    @Guide(description: "Name for this dish.")
    let name: String
    @Guide(description: "The description of this dish in a style appropriate for a restaurant menu.")
    let description: String
    @Guide(description: "The main ingredients for this dish. Need to include required quantity per ingredient.")
    let ingredients: [String]
    @Guide(description: "A cost for this dish in EUR currency, which should be appropriate for the ingredients", )
    let cost: Decimal
    
    var id: String {
        self.name
    }
}

@Generable(description: "A menu of offerings for a restaurant for a single meal.")
struct RestaurantMenu: Identifiable {
    @Guide(description: "The type of meal this menu is for. It has one of the pre-defined values - breakfast, lunch or dinner.")
    let type: MealType
    
    @Guide(description: "The type of restaurant this menu is for. The type has oen of the predefined values - Fine dining, Diner, Casual dining, Fast food, Buffet, Deli or Pub.")
    let restaurantType: RestaurantType
    
    @Guide(description: "A list of menu items, appropriate for the selected type of meal.", .count(4...8))
    let menu: [MenuItem]
    
    var id: String {
        UUID().uuidString
    }
}


// MARK: - Mock data

extension MenuItem {
    static let mockMenuItem = MenuItem(
        name: "Caesar Salad",
        description: "Romaine lettuce tossed in Caesar dressing with parmesan cheese and croutons.",
        ingredients: ["romaine lettuce", "Caesar dressing", "parmesan cheese", "croutons"],
        cost: 10.0
    )
}

extension RestaurantMenu {
    static let mockRestaurantMenu = RestaurantMenu(type: .lunch, restaurantType: .casualDining, menu: [MenuItem.mockMenuItem])
}
