//
//  CustomSelector.swift
//  RestaurantMenu
//
//  Created by Dariy Kutelov on 21.10.25.
//

import SwiftUI

struct CustomSelector<T: Hashable & CaseIterable>: View where T.AllCases.Element: RawRepresentable, T.AllCases.Element.RawValue == String {
    let title: String
    let selectedItems: Set<T>
    let onSelectionChanged: (Set<T>) -> Void
    var tintColor: Color = .mint
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 80, maximum: 120), spacing: 8)
            ], spacing: 8) {
                ForEach(Array(T.allCases), id: \.self) { item in
                    Button(action: {
                        var newSelection = selectedItems
                        if newSelection.contains(item) {
                            newSelection.remove(item)
                        } else {
                            newSelection.insert(item)
                        }
                        onSelectionChanged(newSelection)
                    }) {
                        Text(item.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedItems.contains(item) ? tintColor : Color.gray.opacity(0.2))
                            )
                            .foregroundColor(selectedItems.contains(item) ? .white : .primary)
                    }
                }
            }
        }
    }
}

#Preview {
    VStack {
        CustomSelector<MealType>(
            title: "Select Meal Types:",
            selectedItems: [.lunch],
            onSelectionChanged: { _ in },
            tintColor: .mint
        )
        
        CustomSelector<RestaurantType>(
            title: "Select Restaurant Types:",
            selectedItems: [.casualDining],
            onSelectionChanged: { _ in },
            tintColor: .mint
        )
    }
    .padding()
}
