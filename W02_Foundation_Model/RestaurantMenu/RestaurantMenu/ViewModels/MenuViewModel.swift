//
//  MenuFoodModel.swift
//  RestaurantMenu
//
//  Created by Dariy Kutelov on 21.10.25.
//

import Foundation
import FoundationModels
import Observation

struct DynamicMenu: Identifiable {
    let type: MealType?
    let restaurantType: RestaurantType?
    let menu: [MenuItem]
    
    var id: String {
        "\(type?.rawValue ?? "")-\(restaurantType?.rawValue ?? "")"
    }
}

@Observable class MenuViewModel {
    var menus: [RestaurantMenu.PartiallyGenerated] = []
    var dynamicMenus: [DynamicMenu] = []
    var special: MenuItem?
    var selectedMealTypes: Set<MealType> = [.lunch]
    var selectedRestaurantTypes: Set<RestaurantType> = [.casualDining]
    var createCustomMenu = false
    var ingredients = "lamb, salmon, duck"
    
    private var sortedMealTypes: [MealType] {
        guard selectedMealTypes.count > 1 else { return Array(selectedMealTypes) }
        return selectedMealTypes.sorted { mealType1, mealType2 in
            MealType.allCases.firstIndex(of: mealType1) ?? 0 < MealType.allCases.firstIndex(of: mealType2) ?? 0
        }
    }
    
    var buttonText: String {
        let mealTypesText = sortedMealTypes.map { $0.rawValue.lowercased() }.joined(separator: " and ")
        let restaurantTypesText = Array(selectedRestaurantTypes).map { $0.rawValue.lowercased() }.joined(separator: " and ")
        return "Generating menu for \(mealTypesText) at \(restaurantTypesText)"
    }
    
    private func ingredientArray(from ingredients: String) -> [String] {
        let array = ingredients.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        if array.isEmpty {
            return ["lamb", "salmon", "duck"]
        } else {
            return array
        }
    }
    
    func generateMenus() async {
        dynamicMenus.removeAll()
        
        let menuItemSchema = DynamicGenerationSchema(
            name: "menuItem",
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
        
        let mealSchema = DynamicGenerationSchema(
            name: "menu",
            properties: [
                DynamicGenerationSchema.Property(
                    name: "mealType",
                    schema: DynamicGenerationSchema(
                        name: "mealType",
                        anyOf: MealType.allCases.map { $0.rawValue }
                    )
                ),
                DynamicGenerationSchema.Property(
                    name: "restaurantType",
                    schema: DynamicGenerationSchema(
                        name: "restaurantType",
                        anyOf: RestaurantType.allCases.map { $0.rawValue }
                    )
                ),
                DynamicGenerationSchema.Property(
                    name: "items",
                    description: "An array of 4-8 menu items",
                    schema: DynamicGenerationSchema(
                        arrayOf: menuItemSchema
                    )
                )
            ]
        )
        
        let schema = try? GenerationSchema(root: mealSchema, dependencies: [])
        
        guard let schema = schema else { return }
        
        let instructions = "You are a helpful model assisting with generating realistic restaurant menus."
        let session = LanguageModelSession(instructions: instructions)
        
        for restaurantType in selectedRestaurantTypes {
            for mealType in sortedMealTypes {
                let prompt = 
                """
                Create a \(mealType.rawValue.lowercased()) menu for a \(restaurantType.rawValue.lowercased()) restaurant. 
                Generate 4-8 menu items appropriate for this meal type and restaurant style. 
                In some of the meals take into account the ingredients specified in the prompt.
                If the ingredients are not specified, generate a menu item that is appropriate for the meal type and restaurant style.
                Ingredients: \(ingredients)
                """
                
                do {
                    let streamedResponse = try session.streamResponse(to: prompt, schema: schema)
                    
                    var menuAdded = false
                    
                    for try await partialResponse in streamedResponse {
                        if let partialMenu = parseMenuFromGeneratedContent(partialResponse.content) {
                            if !menuAdded {
                                dynamicMenus.append(partialMenu)
                                menuAdded = true
                            } else {
                                if !dynamicMenus.isEmpty {
                                    dynamicMenus[dynamicMenus.count - 1] = partialMenu
                                }
                            }
                        }
                    }
                } catch {
                    print("Error generating menu for \(restaurantType.rawValue) - \(mealType.rawValue): \(error.localizedDescription)")
                }
            }
        }
    }

    private func parseMenuFromGeneratedContent(_ content: GeneratedContent) -> DynamicMenu? {
        let mealTypeValue = try? content.value(String.self, forProperty: "mealType")
        let restaurantTypeValue = try? content.value(String.self, forProperty: "restaurantType")
        let itemsArray = try? content.value([GeneratedContent].self, forProperty: "items")
        
        var menuItems: [MenuItem] = []
        
        if let itemsArray = itemsArray {
            for itemContent in itemsArray {
                let name = try? itemContent.value(String.self, forProperty: "name")
                let description = try? itemContent.value(String.self, forProperty: "description")
                let ingredientsValue = try? itemContent.value(String.self, forProperty: "ingredients")
                let price = try? itemContent.value(Decimal.self, forProperty: "price")
                
                if let name = name, let description = description, let price = price {
                    let menuItem = MenuItem(
                        name: name,
                        description: description,
                        ingredients: ingredientsValue == nil ? [] : [ingredientsValue!],
                        cost: price
                    )
                    menuItems.append(menuItem)
                }
            }
        }
        
        if !menuItems.isEmpty {
            return DynamicMenu(
                type: mealTypeValue.flatMap { MealType(rawValue: $0) },
                restaurantType: restaurantTypeValue.flatMap { RestaurantType(rawValue: $0) },
                menu: menuItems
            )
        }
        
        return nil
    }
}
