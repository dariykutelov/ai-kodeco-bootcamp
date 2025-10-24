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
        menus.removeAll()
        
        let menuInstructions = """
        You are an expert chef and restaurant menu designer. Your task is to create authentic, appealing restaurant menus that match the specified meal type and restaurant style.
        
        Guidelines:
        - Generate menu items with creative, appealing names appropriate for the restaurant type
        - Write descriptions that are enticing and highlight key ingredients and preparation methods
        - Set prices in EUR that are realistic for the restaurant type (fine dining higher, casual dining moderate, fast food lower)
        - When specific ingredients are mentioned, incorporate them creatively into some (but not all) dishes
        - Ensure all items are appropriate for the specified meal type (breakfast, lunch, or dinner)
        - Vary the dishes to create a balanced, diverse menu
        """
        
        let menuSession = LanguageModelSession(instructions: menuInstructions)
        
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
                    let streamedResponse = menuSession.streamResponse(to: prompt, generating: RestaurantMenu.self)
                    
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
        
        await createShoppingListFromMenus()
    }
    
    private func createShoppingListFromMenus() async {
        let shoppingTool = AddToShoppingList()
        let toolInstructions = """
        You are a helpful assistant that analyzes restaurant menus and creates shopping lists.
        Your job is to extract all unique ingredients from the provided menu and use the addReminder tool to create a shopping list for the user.
        Be thorough and extract all ingredients mentioned.
        """
        
        let toolSession = LanguageModelSession(tools: [shoppingTool], instructions: toolInstructions)
        
        var allIngredients: [String] = []
        for menu in menus {
            if let menuItems = menu.menu {
                for item in menuItems {
                    if let ingredients = item.ingredients {
                        allIngredients.append(contentsOf: ingredients)
                    }
                }
            }
        }
        
        let uniqueIngredients = Array(Set(allIngredients))
        
        let analysisPrompt = """
        I have generated restaurant menus with the following ingredients:
        \(uniqueIngredients.joined(separator: ", "))
        
        Please create a shopping list reminder with all these unique ingredients so I can remember to buy them.
        """
        
        do {
            _ = try await toolSession.respond(to: analysisPrompt)
        } catch {
            print("Error creating shopping list: \(error.localizedDescription)")
        }
    }
}
