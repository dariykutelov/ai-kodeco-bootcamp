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
                    Text("€\(menuItemCost.formatted(.number.precision(.fractionLength(2))))")
                        .foregroundStyle(.indigo)
                }
            }
            .font(.title3)
            
            Text(menuItem.description ?? "")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.subheadline)
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
        .padding(.bottom)
    }
}

#Preview {

    MenuItemView(menuItem: MenuItem.mockMenuItem.asPartiallyGenerated())
}
