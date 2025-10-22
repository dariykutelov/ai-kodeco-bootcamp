//
//  MenuFoodModel.swift
//  RestaurantMenu
//
//  Created by Dariy Kutelov on 21.10.25.
//

import Foundation
import FoundationModels
import Observation

@Observable class MenuViewModel {
    var menus: [RestaurantMenu.PartiallyGenerated] = []
    var special: MenuItem?
    var selectedMealTypes: Set<MealType> = [.lunch]
    var selectedRestaurantTypes: Set<RestaurantType> = [.casualDining]
    var createCustomMenu = false
    var ingredients = "lamb, salmon, duck"
    
    private var sortedMealTypes: [MealType] {
        guard selectedMealTypes.count > 1 else { return Array(selectedMealTypes) }
        let order: [MealType] = [.breakfast, .lunch, .dinner]
        return selectedMealTypes.sorted { mealType1, mealType2 in
            order.firstIndex(of: mealType1) ?? 0 < order.firstIndex(of: mealType2) ?? 0
        }
    }
    
    private func ingredientArray(from ingredients: String) -> [String] {
        let array = ingredients.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        if array.isEmpty {
            return ["lamb", "salmon", "duck"]
        } else {
            return array
        }
    }
    
    func generateLunchMenu() async {
        menus.removeAll()
        
        let instructions = "You are a helpful model assisting with generating realistic restaurant menus."
        let session = LanguageModelSession(instructions: instructions)
        
        for restaurantType in selectedRestaurantTypes {
            for mealType in sortedMealTypes {
                let prompt = "Create a \(mealType.rawValue.lowercased()) menu for a \(restaurantType.rawValue.lowercased()) restaurant. Generate 4-8 menu items appropriate for this meal type and restaurant style."
                
                do {
                    let streamedResponse = session.streamResponse(to: prompt, generating: RestaurantMenu.self)
                    
                    var menuAdded = false
                    
                    for try await partialResponse in streamedResponse {
                        if !menuAdded {
                            menus.append(partialResponse.content)
                            menuAdded = true
                        } else {
                            if !menus.isEmpty {
                                menus[menus.count - 1] = partialResponse.content
                            }
                        }
                    }
                } catch {
                    print("Error generating menu for \(restaurantType.rawValue) - \(mealType.rawValue): \(error.localizedDescription)")
                }
            }
        }
    }
    
    func generateMenuSpecial(ingredients: String) async {
        let specialMealSchema = DynamicGenerationSchema(
            name: "specialmenuitem",
            properties: [
                DynamicGenerationSchema.Property(
                    name: "ingredients",
                    schema: DynamicGenerationSchema(
                        name: "ingredients",
                        anyOf: ingredientArray(from: ingredients)
                    )
                ),
                
                DynamicGenerationSchema.Property(
                    name: "name",
                    schema: DynamicGenerationSchema(type: String.self)
                ),
                DynamicGenerationSchema.Property(
                    name: "description",
                    schema: DynamicGenerationSchema(type: String.self)
                ),
                DynamicGenerationSchema.Property(
                    name: "price",
                    schema: DynamicGenerationSchema(type: Decimal.self)
                )
            ]
        )
        
        let schema = try? GenerationSchema(root: specialMealSchema, dependencies: [])
        
        guard let schema = schema else { return }
        
        let session = LanguageModelSession(instructions: "You are a helpful model assisting with generating realistic restaurant menus.")
        let specialPrompt = "Produce a lunch special menu item that is focused on the specified ingredient."
        let response = try? await session.respond(to: specialPrompt, schema: schema)
        
        let name = try? response?.content.value(String.self, forProperty: "name")
        let ingredients = try? response?.content.value(String.self, forProperty: "ingredients")
        let description = try? response?.content.value(String.self, forProperty: "description")
        let price = try? response?.content.value(Decimal.self, forProperty: "price")
        let specialItem = MenuItem(
            name: name ?? "",
            description: description ?? "",
            ingredients: ingredients == nil ? [] : [ingredients!],
            cost: price ?? 0.0
        )
        special = specialItem
    }
}
