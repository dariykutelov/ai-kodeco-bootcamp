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
    var menu: RestaurantMenu.PartiallyGenerated?
    var special: MenuItem?
    var selectedMealTypes: Set<MealType> = [.lunch]
    var selectedRestaurantTypes: Set<RestaurantType> = [.casualDining]
    var createCustomMenu = false
    var ingredients = "lamb, salmon, duck"
    
    private func ingredientArray(from ingredients: String) -> [String] {
        let array = ingredients.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        if array.isEmpty {
            return ["lamb", "salmon", "duck"]
        } else {
            return array
        }
    }
    
    func generateLunchMenu() async {
        let instructions = "You are a helpful model assisting with generating realistic restaurant menus."
        let session = LanguageModelSession(instructions: instructions)
        let prompt = "Create a menu for lunch at an Korean restaurant"
        let streamedResponse = session.streamResponse(to: prompt,
                                                      generating: RestaurantMenu.self)
        do {
            for try await partialResponse in streamedResponse {
                menu = partialResponse.content
            }
        } catch {
            print(error.localizedDescription)
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
