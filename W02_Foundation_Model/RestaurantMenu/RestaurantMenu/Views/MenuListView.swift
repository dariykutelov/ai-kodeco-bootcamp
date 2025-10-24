//
//  MenuListView.swift
//  RestaurantMenu
//
//  Created by Dariy Kutelov on 21.10.25.
//

import SwiftUI
import FoundationModels

struct MenuListView: View {
    var menus: [DynamicMenu]

    var body: some View {
        let _ = print("MenuListView body called with \(menus.count) menus")
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    if menus.isEmpty {
                        ProgressView("Generating menus...")
                            .font(.title2)
                            .padding()
                    } else {
                        ForEach(menus, id: \.id) { menu in 
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    if let menuType = menu.type?.rawValue {
                                    Text(menuType)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    }
                                    Spacer()
                                    
                                    if let reataurantType = menu.restaurantType?.rawValue {
                                        Text(reataurantType)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal)
                                
                                if !menu.menu.isEmpty {
                                    ForEach(menu.menu, id: \.id) { item in
                                        MenuItemView(menuItem: item)
                                    }
                                } else {
                                    Text("No menu items available")
                                        .foregroundColor(.secondary)
                                        .italic()
                                        .padding()
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Generated Menus")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

//#Preview {
//    MenuListView()
//}
