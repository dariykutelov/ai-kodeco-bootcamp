//
//  RestaurantMenu.swift
//  RestaurantMenu
//
//  Created by Dariy Kutelov on 21.10.25.
//

import Foundation
import FoundationModels

@Generable(description: "Meal type for a restaurant menu. The type has predefined values - breakfast, lunch and dinner.")
enum MealType: String, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
}

@Generable(description: "A single dish for a restaurant menu.")
struct MenuItem {
    @Guide(description: "Name for this dish.")
    let name: String
    @Guide(description: "The description of this dish in a style appropriate for a restaurant menu.")
    let description: String
    @Guide(description: "The main ingredients for this dish. Need to include required quantity per ingredient.")
    let ingredients: [String]
    @Guide(description: "A cost for this dish in EUR currency, which should be appropriate for the ingredients", )
    let cost: Decimal
}

@Generable(description: "A menu of offerings for a restaurant for a single meal.")
struct RestaurantMenu {
    let type: MealType
    let restaurantType: RestaurantType
    
    @Guide(description: "A list of menu items, appropriate for the selected type of meal.", .count(4...8))
    let menu: [MenuItem]
}
