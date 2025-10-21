//
//  MenuListView.swift
//  RestaurantMenu
//
//  Created by Dariy Kutelov on 21.10.25.
//

import SwiftUI
import FoundationModels

struct MenuListView: View {
    var menu: RestaurantMenu.PartiallyGenerated?
    var special: MenuItem?
    
    var body: some View {
        VStack {
            if let special = special {
                MenuItemView(menuItem: special.asPartiallyGenerated())
                Text("Today's Special")
                    .font(.title2)
                Divider()
            }
            
            if let menu = menu, let menuItems = menu.menu {
                List(menuItems) { item in
                    MenuItemView(menuItem: item)
                }
            }
        }
        .padding()
    }
}

#Preview {
    MenuListView()
}
