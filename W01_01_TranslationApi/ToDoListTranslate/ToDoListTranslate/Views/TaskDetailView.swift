import SwiftUI

struct TaskDetailView: View {
    @Environment(ToDoTaskViewModel.self) private var viewModel: ToDoTaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    let task: ToDoTask
    @State private var currentStatus: ToDoTaskStatus
    
    init(task: ToDoTask) {
        self.task = task
        _currentStatus = State(initialValue: task.status)
    }
    
    var body: some View {
        List {
            Section("Task Information") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(task.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(task.description)
                        .font(.body)
                }
                .padding(.vertical, 4)
            }
            
            Section("Status") {
                Picker("Status", selection: $currentStatus) {
                    Text("Pending").tag(ToDoTaskStatus.pending)
                    Text("In Progress").tag(ToDoTaskStatus.inProgress)
                    Text("Completed").tag(ToDoTaskStatus.completed)
                    Text("Cancelled").tag(ToDoTaskStatus.cancelled)
                }
                .pickerStyle(.menu)
                .onChange(of: currentStatus) {
                    updateTaskStatus()
                }
            }
            
            Section("Details") {
                HStack {
                    Text("Priority")
                    Spacer()
                    priorityBadge(task.priority)
                }
                
                HStack {
                    Text("Created")
                    Spacer()
                    Text(task.createdAt, style: .date)
                        .foregroundStyle(.secondary)
                }
                
                if let dueDate = task.dueDate {
                    HStack {
                        Text("Due Date")
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(dueDate, style: .date)
                            Text(dueDate, style: .time)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section {
                Button(role: .destructive) {
                    deleteTask()
                } label: {
                    HStack {
                        Spacer()
                        Label("Delete Task", systemImage: "trash")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func priorityBadge(_ priority: ToDoTaskPriority) -> some View {
        HStack {
            Image(systemName: "flag.fill")
            Text(priorityText(priority))
        }
        .font(.caption)
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(priorityColor(priority))
        .clipShape(Capsule())
    }
    
    private func priorityText(_ priority: ToDoTaskPriority) -> String {
        switch priority {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    private func priorityColor(_ priority: ToDoTaskPriority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    private func updateTaskStatus() {
        guard let taskId = task.id else { return }
        
        if let index = viewModel.tasks.firstIndex(where: { $0.id == taskId }) {
            viewModel.tasks[index].status = currentStatus
        }
    }
    
    private func deleteTask() {
        guard let taskId = task.id else { return }
        viewModel.removeTask(taskId)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(
            task: ToDoTask(
                id: "1",
                title: "Sample Task",
                description: "This is a sample task description that shows how the detail view looks.",
                status: .inProgress,
                priority: .high,
                createdAt: Date(),
                dueDate: Date().addingTimeInterval(86400)
            )
        )
        .environment(ToDoTaskViewModel())
    }
}

