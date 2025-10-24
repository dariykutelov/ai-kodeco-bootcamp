//
//  Menu.swift
//  RestaurantMenu
//
//  Created by Dariy Kutelov on 24.10.25.
//

import Foundation
import FoundationModels


struct Menu {
    var properties: [DynamicGenerationSchema.Property] = []
    
//    mutating func addMealType(_ mealType: MealType) {
//        let mealType = DynamicGenerationSchema.Property(
//            name: "mealType",
//            schema: DynamicGenerationSchema(type: MealType.self)
//        )
//        
//        properties.append(mealType)
//    }
//    
//    mutating func addRestaurantType(_ restaurantType: RestaurantType) {
//        let property = DynamicGenerationSchema.Property(
//            name: "restaurantType",
//            schema: DynamicGenerationSchema(type: RestaurantType.self)
//        )
//    }
    
    mutating func addMenuItems(mealType: MealType, restaurantType: RestaurantType) {
        let menuItems = DynamicGenerationSchema.Property(
            name: "menuItems",
            schema: DynamicGenerationSchema(
                arrayOf: DynamicGenerationSchema(referenceTo: "MenuItem")
            )
        )
    }
}

