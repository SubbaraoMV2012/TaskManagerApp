//
//  TaskDetailView.swift
//  TaskManagerApp
//
//  Created by SubbaRao MV on 27/02/25.
//

import SwiftUI

struct TaskDetailView: View {
    @Binding var task: TaskModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrastMode
    
    @ObservedObject var viewModel: TaskDetailViewModel
    @Namespace private var animationNamespace
    
    init(task: Binding<TaskModel>, viewModel: TaskDetailViewModel) {
        self._task = task
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.task.title)
                .font(.headline)
                .bold()
                .matchedGeometryEffect(id: viewModel.task.id, in: animationNamespace)
                .accessibilityLabel("Task Title: \(viewModel.task.title)")
                .accessibilityAddTraits(.isHeader)
                .dynamicTypeSize(.large ... .xxxLarge)
            
            if let description = viewModel.task.taskDescription, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Task Description: \(description)")
                    .dynamicTypeSize(.large ... .xxxLarge)
            }
            
            HStack {
                Text("Priority: \(viewModel.task.priority.rawValue.capitalized)")
                    .font(.headline)
                    .accessibilityLabel("Task Priority: \(viewModel.task.priority.rawValue.capitalized)")
                    .dynamicTypeSize(.large ... .xxxLarge)
                Spacer()
                Text("Due Date: \(viewModel.task.dueDate, style: .date)")
                    .font(.subheadline)
                    .accessibilityLabel("Due Date: \(viewModel.task.dueDate, style: .date)")
                    .dynamicTypeSize(.large ... .xxxLarge)
            }
            
            Button(action: {
                if viewModel.task.status == .pending {
                    withAnimation {
                        viewModel.toggleCompletion()
                    }
                }
            }) {
                Label(viewModel.task.status == .pending ? "Mark as complete" : "Task Completed", systemImage: viewModel.task.status == .pending ? "circle" : "checkmark.circle.fill")
                    .frame(height: 45)
                    .padding()
                    .background(contrastAdaptiveColor())
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .font(.body)
                    .dynamicTypeSize(.large ... .xxxLarge)
            }
            .accessibilityLabel(viewModel.task.status == .pending ? "Mark task as complete" : "Task already completed")
            .accessibilityHint("Double tap to change status")
            Spacer()
        }
        .padding()
        .navigationTitle("Task Details")
        .transition(.opacity)
        .animation(.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 0.2), value: task)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    viewModel.deleteTask()
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                }
                .accessibilityLabel("Delete Task")
                .accessibilityHint("Double tap to delete this task permanently")
                .keyboardShortcut(.delete)
            }
        }
        .onAppear {
            viewModel.onTaskUpdated = {
                task.status = viewModel.task.status
            }
        }
    }
    
    private func contrastAdaptiveColor() -> Color {
        contrastMode == .increased ? .primary : (viewModel.task.status == .pending ? Color.red : Color.green)
    }
}

#Preview {
    TaskDetailView(
        task: .constant(TaskModel(
            id: UUID(),
            title: "Title",
            taskDescription: "Description",
            priority: .low,
            dueDate: Date(),
            status: .pending,
            sortIndex: 0
        )),
        viewModel: TaskDetailViewModel(task: TaskModel(
            id: UUID(),
            title: "Title",
            taskDescription: "Description",
            priority: .low,
            dueDate: Date(),
            status: .pending,
            sortIndex: 0
        ))
    )
}
