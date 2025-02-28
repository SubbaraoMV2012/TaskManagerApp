//
//  TaskCreationView.swift
//  TaskManagerApp
//
//  Created by SubbaRao MV on 27/02/25.
//

import SwiftUI
enum Field {
    case title, description
}

struct TaskCreationView: View {
    @State var viewModel = TaskCreationViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrastMode
    @FocusState private var focusedField: Field?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Title", text: $viewModel.title)
                        .font(.headline)
                        .dynamicTypeSize(.large ... .xxxLarge)
                        .accessibilityLabel("Task title")
                        .accessibilityHint("Enter a title for your task. This field is required.")
                        .focused($focusedField, equals: .title)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .description
                        }
                    TextField("Description", text: $viewModel.description)
                        .font(.body)
                        .dynamicTypeSize(.large ... .xxxLarge)
                        .accessibilityLabel("Task description")
                        .accessibilityHint("Enter an optional description for your task.")
                        .focused($focusedField, equals: .description)
                        .submitLabel(.done)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $viewModel.priority) {
                        ForEach(TaskPriority.allCases, id: \ .self) { priority in
                            Text(priority.rawValue.capitalized)
                                .font(.body)
                                .dynamicTypeSize(.large ... .xxxLarge)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .accessibilityLabel("Task priority")
                    .accessibilityHint("Swipe left or right to select task priority.")
                }
                
                Section("Due Date") {
                    DatePicker("Select a date", selection: $viewModel.dueDate, displayedComponents: .date)
                        .font(.body)
                        .dynamicTypeSize(.large ... .xxxLarge)
                        .accessibilityLabel("Due date")
                        .accessibilityHint("Pick a due date for your task.")
                }
            }
            .navigationTitle("New Task")
            .dynamicTypeSize(.large ... .xxxLarge)
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.body)
                    .dynamicTypeSize(.large ... .xxxLarge)
                    .accessibilityLabel("Cancel")
                    .accessibilityHint("Dismiss task creation without saving.")
                    .keyboardShortcut(.cancelAction)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        withAnimation {
                            viewModel.saveTask()
                        }
                        dismiss()
                    }
                    .font(.body)
                    .dynamicTypeSize(.large ... .xxxLarge)
                    .disabled(viewModel.title.isEmpty)
                    .accessibilityLabel("Save Task")
                    .accessibilityHint(viewModel.title.isEmpty ? "Enter a title to enable saving." : "Save the task and dismiss this screen.")
                    .keyboardShortcut("S", modifiers: .command)
                }
            }
        }
        .onAppear() {
            focusedField = .title
        }
    }
}

#Preview {
    TaskCreationView(viewModel: TaskCreationViewModel())
}
