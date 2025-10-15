//
//  TaskListView.swift
//  ToDoListTranslate
//
//  Created by Dariy Kutelov on 13.10.25.
//

import SwiftUI

struct TaskListView: View {
    @Environment(ToDoTaskViewModel.self) private var viewModel: ToDoTaskViewModel

    var body: some View {
        NavigationStack {
            List(viewModel.tasks) { task in
                NavigationLink {
                    TaskDetailView(task: task)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                            .font(.headline)
                        Text(task.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
            }
            .overlay(alignment: .center) {
                if viewModel.tasks.isEmpty {
                    ContentUnavailableView("No tasks available",
                                           systemImage: "nosign")
                }
            }
            .navigationTitle(Text("Tasks"))
        }
    }
}

#Preview {
    TaskListView()
        .environment(ToDoTaskViewModel())
}
