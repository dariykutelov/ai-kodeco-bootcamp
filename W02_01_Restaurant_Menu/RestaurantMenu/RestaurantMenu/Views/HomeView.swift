//
//  ContentView.swift
//  RestaurantMenu
//
//  Created by Dariy Kutelov on 21.10.25.
//

import SwiftUI
import FoundationModels

struct HomeView: View {
    @State private var viewModel = MenuViewModel()
    @State private var showMenuList = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                CustomSelector<MealType>(
                    title: "Select Meal Types:",
                    selectedItems: viewModel.selectedMealTypes,
                    onSelectionChanged: { viewModel.selectedMealTypes = $0 },
                    tintColor: .orange
                )
                
                CustomSelector<RestaurantType>(
                    title: "Select Restaurant Types:",
                    selectedItems: viewModel.selectedRestaurantTypes,
                    onSelectionChanged: { viewModel.selectedRestaurantTypes = $0 },
                    tintColor: .green
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Create Custom Menu")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Toggle("", isOn: $viewModel.createCustomMenu)
                            .labelsHidden()
                            .tint(.indigo)
                    }
                    
                    if viewModel.createCustomMenu {
                        VStack(alignment: .leading) {
                            Text("Special Menu")
                                .fontWeight(.semibold)
                            Text("Comma separated list of possible ingredients.")
                                .foregroundStyle(.secondary)
                            TextField(
                                "Ingredients for Special",
                                text: $viewModel.ingredients
                            )
                            .textFieldStyle(.roundedBorder)
                            .padding(.vertical, 8)
                        }
                        .font(.subheadline)
                    }
                }
                
                Spacer()
                
                Button {
                    showMenuList.toggle()
                    Task {
                        await viewModel.generateLunchMenu()
                        await viewModel.generateMenuSpecial(ingredients: viewModel.ingredients)
                    }
                } label: {
                    Label("Generate Lunch Menu", systemImage: "menucard")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .padding(.vertical)
                .tint(.black)
            }
            .padding()
            .sheet(isPresented: $showMenuList) {
                MenuListView(
                    menus: viewModel.menus
                )
            }
            .navigationTitle("Create Your Menu")
        }
    }
}

#Preview {
    HomeView()
}
