//
//  ContentView.swift
//  ToDoListTranslate
//
//  Created by Dariy Kutelov on 13.10.25.
//

import SwiftUI
import Translation

struct ContentView: View {
    @Environment(ToDoTaskViewModel.self) private var viewModel: ToDoTaskViewModel
    @State private var isAddTaskPresented: Bool = false
    @State private var configuration: TranslationSession.Configuration?
    
    var body: some View {
        NavigationStack {
            VStack {
                TaskListView()
                
                if !viewModel.availableLanguages.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Translation Settings")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LanguagePickersView()
                            .padding(.horizontal)
                    }
                }
                
                Button {
                    translateAll()
                } label : {
                    Label("Translate All", systemImage: "arrow.2.circlepath.circle")
                        .padding(.horizontal)
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        isAddTaskPresented.toggle()
                    } label: {
                        Label("Add task", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddTaskPresented) {
                NavigationStack {
                    NewTask()
                }
            }
            .translationTask(configuration) { session in
              Task {
                await viewModel.translateSequence(using: session)
              }
            }
        }
    }
    
    private func translateAll() {
        viewModel.identifyLanguage()
        
        if configuration == nil {
            configuration = .init(
                source: viewModel.translateFrom,
                target: viewModel.translateTo
                )
            return
        }
        
        configuration?.invalidate()
    }
}

struct LanguagePickersView: View {
    @Environment(ToDoTaskViewModel.self) private var viewModel: ToDoTaskViewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack(spacing: 12) {
            Picker("Source Language", selection: $viewModel.translateFrom) {
                Text("Auto-detect").tag(nil as Locale.Language?)
                ForEach(viewModel.availableLanguages) { language in
                    Text(language.localizedName())
                        .tag(Optional(language.locale))
                }
            }
            .pickerStyle(.menu)
            
            Picker("Target Language", selection: $viewModel.translateTo) {
                ForEach(viewModel.availableLanguages) { language in
                    Text(language.localizedName())
                        .tag(Optional(language.locale))
                }
            }
            .pickerStyle(.menu)
        }
    }
}

#Preview {
    ContentView()
        .environment(ToDoTaskViewModel())
}

