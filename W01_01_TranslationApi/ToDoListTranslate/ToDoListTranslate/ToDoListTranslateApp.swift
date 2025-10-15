//
//  ToDoListTranslateApp.swift
//  ToDoListTranslate
//
//  Created by Dariy Kutelov on 13.10.25.
//

import SwiftUI

@main
struct ToDoListTranslateApp: App {
    @State private var toDoTaskViewModel = ToDoTaskViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(toDoTaskViewModel)
        }
    }
}
