//
//  MealType.swift
//  RestaurantMenu
//
//  Created by Dariy Kutelov on 24.10.25.
//

import Foundation
import FoundationModels

@Generable(description: "Meal type for a restaurant menu. The type has one of the predefined values - breakfast, lunch and dinner.")
enum MealType: String, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
}
