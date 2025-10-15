//
//  NewTask.swift
//  ToDoListTranslate
//
//  Created by Dariy Kutelov on 13.10.25.
//

import SwiftUI

struct NewTask: View {
    @Environment(ToDoTaskViewModel.self) private var viewModel: ToDoTaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var priority: ToDoTaskPriority = .low
    @State private var dueDate: Date = Date()
    
    private var isFormValid: Bool {
        !title.isEmpty && !description.isEmpty && dueDate > Date()
    }
    
    private func addTask() {
        let toDoTask = ToDoTask(
            id: UUID().uuidString,
            title: title,
            description: description,
            status: .inProgress,
            priority: priority,
            createdAt: Date(),
            dueDate: dueDate
        )
        
        viewModel.addTask(toDoTask)
        dismiss()
    }
    
    
    var body: some View {
        VStack {
            Form {
                Section("Task Title and Description") {
                    TextField("Title", text: $title)
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        Text("Low").tag(ToDoTaskPriority.low)
                        Text("Medium").tag(ToDoTaskPriority.medium)
                        Text("High").tag(ToDoTaskPriority.high)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Due Date") {
                    DatePicker("Due on", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("New Task")
            
            Button {
                addTask()
            } label: {
                Text("Add Task")
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isFormValid)
            .opacity(isFormValid ? 1 : 0.5)
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        NewTask()
            .environment(ToDoTaskViewModel())
    }
}
