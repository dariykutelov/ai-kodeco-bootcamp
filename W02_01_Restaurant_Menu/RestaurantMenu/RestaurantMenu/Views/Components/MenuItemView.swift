//
//  MenuItemView.swift
//  RestaurantMenu
//
//  Created by Dariy Kutelov on 21.10.25.
//

import SwiftUI
import FoundationModels

struct MenuItemView: View {
    var menuItem: MenuItem.PartiallyGenerated
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack() {
                Text(menuItem.name ?? "")
                    .foregroundStyle(.orange)
                    .fontWeight(.semibold)
                
                Spacer()
            
                if let menuItemCost = menuItem.cost {
                    Text(menuItemCost, format: .currency(code: "EUR").locale(Locale(identifier: "en_US")))
                        .foregroundStyle(.indigo)
                }
            }
            .font(.title2)
            
            Text(menuItem.description ?? "")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.body)
                .foregroundStyle(.secondary)
            
            if let menuItemIngredients = menuItem.ingredients {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ingredients")
                        .font(.headline)
                        .foregroundStyle(.indigo)
                    Text(menuItemIngredients.joined(separator: " • "))
                        .font(.subheadline)
                }
            }
        }
    }
}

#Preview {
    let item = MenuItem(
      name: "Caesar Salad",
      description: "Romaine lettuce tossed in Caesar dressing with parmesan cheese and croutons.",
      ingredients: ["romaine lettuce", "Caesar dressing", "parmesan cheese", "croutons"],
      cost: 10.0
    )
    MenuItemView(menuItem: item.asPartiallyGenerated())
}
