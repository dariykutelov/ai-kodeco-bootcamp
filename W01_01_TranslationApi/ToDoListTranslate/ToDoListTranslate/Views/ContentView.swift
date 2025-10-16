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
                
                // Status messages for user feedback
                if !viewModel.translationStatusMessage.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: viewModel.isDeviceLanguageSupported ? "exclamationmark.triangle.fill" : "xmark.circle.fill")
                                .foregroundColor(viewModel.isDeviceLanguageSupported ? .orange : .red)
                            Text("Translation Status")
                                .font(.headline)
                                .foregroundColor(viewModel.isDeviceLanguageSupported ? .orange : .red)
                        }
                        
                        Text(viewModel.translationStatusMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(viewModel.isDeviceLanguageSupported ? Color.orange.opacity(0.1) : Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
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
        if configuration == nil {
            configuration = .init()
            return
        }
        
        configuration?.invalidate()
    }
}


#Preview {
    ContentView()
        .environment(ToDoTaskViewModel())
}

