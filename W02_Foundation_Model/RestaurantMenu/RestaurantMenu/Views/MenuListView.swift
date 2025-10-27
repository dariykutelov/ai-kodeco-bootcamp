//
//  MenuListView.swift
//  RestaurantMenu
//
//  Created by Dariy Kutelov on 21.10.25.
//

import SwiftUI
import FoundationModels

struct MenuListView: View {
    var menus: [RestaurantMenu.PartiallyGenerated]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    if menus.isEmpty {
                        ProgressView("Generating ...")
                            .font(.title2)
                            .padding()
                    } else {
                        ForEach(menus, id: \.id) { menu in 
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    if let menuType = menu.type?.rawValue {
                                    Text(menuType)
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                    }
                                    Spacer()
                                    
                                    if let reataurantType = menu.restaurantType?.rawValue {
                                        Text(reataurantType)
                                            .font(.title2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.bottom)
                                
                                if let menuItems = menu.menu, !menuItems.isEmpty {
                                    ForEach(menuItems, id: \.id) { item in
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
            .navigationTitle("Suggested Menus")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

    #Preview {
        MenuListView(menus: [RestaurantMenu.mockRestaurantMenu.asPartiallyGenerated()])
    }   
