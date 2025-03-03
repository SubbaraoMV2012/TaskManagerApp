//
//  TaskListView.swift
//  TaskManagerApp
//
//  Created by SubbaRao MV on 27/02/25.
//

import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel: TaskListViewModel
    @State private var showingAddTask = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrastMode
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskEntity.sortIndex, ascending: true)]
    ) private var fetchedTasks: FetchedResults<TaskEntity>
    @State private var showSettings = false
    @State private var isLoading = true
    
    init() {
        _viewModel = StateObject(wrappedValue: TaskListViewModel())
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                sortingAndFilteringSection
                    .accessibilityElement(children: .combine)
                
                RingProgressBar(progress: viewModel.completionPercentage)
                    .padding()
                    .accessibilityLabel("Task Completion")
                    .accessibilityValue("\(Int(viewModel.completionPercentage * 100))% completed")
                if isLoading {
                    ForEach(0..<5, id: \.self) { _ in
                        ShimmmerPlaceholoderTask()
                            .transition(.opacity)
                    }
                } else {
                    taskList
                        .keyboardShortcut(.defaultAction)
                }
                
                Spacer()
                
                UndoSnackbarView(isShowing: $viewModel.showUndoSnackbar, isDeleted: $viewModel.isDeleteUndo, message: $viewModel.snackbarMessage, onUndo: { deleted in
                    deleted ? viewModel.undoDeletedTask() : viewModel.undoTaskStatus()
                })
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    PulsingButton {
                        showingAddTask = true
                    }
                    .foregroundColor(viewModel.accentColor)
                    .keyboardShortcut("N", modifiers: .command)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showSettings.toggle()
                    }) {
                        Image(systemName: "gearshape.fill")
                            .imageScale(.large)
                    }
                    .foregroundColor(viewModel.accentColor)
                    .accessibilityLabel("Show setting")
                    .accessibilityHint("Tap to show settings to accent color, theme, and more")
                }
            }
            .sheet(isPresented: $showingAddTask) {
                TaskCreationView(viewModel: TaskCreationViewModel(onTaskAdded: { newTask in
                    viewModel.updateTasks(fetchedTasks)
                }))
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .onAppear {
                loadTasks()
            }
            .dynamicTypeSize(.large ... .xxxLarge)
        }
    }
    
    private func loadTasks() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            viewModel.updateTasks(fetchedTasks)
            isLoading = false
        }
    }
    
    private var sortingAndFilteringSection: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading) {
                Text("Sort by")
                    .font(.headline)
                    .dynamicTypeSize(.large ... .xxxLarge)
                    .padding(.leading, 16)
                Picker("", selection: $viewModel.sortOption) {
                    Text("Priority").tag(SortOption.byPriority)
                    Text("Due Date").tag(SortOption.byDueDate)
                    Text("Alphabetically").tag(SortOption.byAlphabetically)
                }
                .pickerStyle(MenuPickerStyle())
                .accessibilityIdentifier("Sort tasks")
            }
            
            VStack(alignment: .leading) {
                Text("Filter")
                    .font(.headline)
                    .dynamicTypeSize(.large ... .xxxLarge)
                    .padding(.leading, 16)
                Picker("", selection: $viewModel.filterStatus) {
                    Text("All").tag(nil as TaskStatus?)
                    Text("Completed").tag(TaskStatus.completed as TaskStatus?)
                    Text("Pending").tag(TaskStatus.pending as TaskStatus?)
                }
                .pickerStyle(MenuPickerStyle())
                .accessibilityIdentifier("Filter tasks")
            }
            Spacer()
        }
        .padding(.top, 16)
        .onChange(of: viewModel.sortOption, {
            viewModel.updateTasks(fetchedTasks)
        })
        .onChange(of: viewModel.filterStatus, {
            viewModel.updateTasks(fetchedTasks)
        })
    }
    
    private var taskList: some View {
        List {
            //        ScrollView {
            //            LazyVStack {
            if viewModel.tasks.isEmpty {
                EmptyStateView {
                    showingAddTask = true
                }
            } else {
                ForEach(viewModel.tasks, id: \.id) { task in
                    taskRow(for: task)
                        .transition(.opacity)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                }
                .onMove(perform: moveTask)
            }
            //            }
            //            .padding(.top, 10)
            //        }
        }
    }
    
    
    private func moveTask(from source: IndexSet, to destination: Int) {
        withAnimation {
            viewModel.moveTask(from: source, to: destination)
            HapticFeedback.trigger()
        }
    }
    
    
    @ViewBuilder
    private func taskRow(for task: TaskModel) -> some View {
        NavigationLink(destination: TaskDetailView(
            task: .constant(task),
            viewModel: TaskDetailViewModel(
                task: task,
                onTaskDeleted: { viewModel.objectWillChange.send() }))) {
                    TaskRowView(task: task)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        withAnimation {
                            viewModel.deleteTask(task: task)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
                .swipeActions(edge: .leading) {
                    Button {
                        withAnimation {
                            viewModel.toggleTaskStatus(task: task)
                        }
                    } label: {
                        Label(task.status == .pending ? "Complete" : "Undo",
                              systemImage: task.status == .pending ? "checkmark.circle.fill" : "arrow.uturn.backward")
                    }
                    .tint(task.status == .pending ? .green : .yellow)
                }
    }
    
}

struct TaskRowView: View {
    let task: TaskModel
    @Environment(\.colorSchemeContrast) private var contrastMode
    
    var body: some View {
        HStack {
            Text(task.title)
                .font(.body)
                .dynamicTypeSize(.large ... .xxxLarge)
                .foregroundColor(contrastAdaptiveColor())
                .accessibilityLabel(task.title)
                .accessibilityHint("Double tap to open details")
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(DynamicColors.cardBackground)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
        )
        .cornerRadius(10)
        .shadow(radius: 2)
        .accessibilityElement(children: .combine)
    }
    
    private func contrastAdaptiveColor() -> Color {
        contrastMode == .increased ? .primary : (task.status == .completed ? .green : .gray)
    }
}

struct PulsingButton: View {
    @State private var isPulsing = false
    @State private var isTapped = false
    var onTap: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.2)) {
                isTapped = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    isTapped = false
                }
            }
            onTap()
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.title)
                .scaleEffect(isTapped ? 1.2 : (isPulsing ? 1.1 : 1.0))
                .onAppear {
                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                        isPulsing = true
                    }
                }
        }
        .accessibilityLabel("Add Task")
        .accessibilityIdentifier("AddTaskButton")
    }
}

struct UndoSnackbarView: View {
    @Binding var isShowing: Bool
    @Binding var isDeleted: Bool
    @Binding var message: String
    var onUndo: ((Bool) -> Void)
    
    var body: some View {
        if isShowing {
            VStack {
                Spacer()
                HStack {
                    Text(message)
                        .foregroundColor(.white)
                        .accessibilityLabel("\(message)")
                        .accessibilityHint("Double tap to undo")
                    Spacer()
                    if isDeleted {
                        Button("Undo") {
                            onUndo(isDeleted)
                        }
                        .foregroundColor(.yellow)
                        .accessibilityLabel(isDeleted ? "Undo deletion" : "Undo Completion")
                        .accessibilityHint(isDeleted ? "Restore deleted task" : "Task moved to pending" )
                        
                        Button("Ok") {
                            isShowing = false
                        }
                        .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(10)
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .frame(height: 50)
        }
    }
}

struct EmptyStateView: View {
    var onAddTask: () -> Void
    
    var body: some View {
        
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.badge.questionmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
                    .opacity(0.8)
                
                Text("No tasks yet!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .dynamicTypeSize(.large ... .xxxLarge)
                
                Text("Stay productive! Start by adding a new task.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .dynamicTypeSize(.large ... .xxxLarge)
                    .foregroundColor(DynamicColors.text)
                    .padding(.horizontal, 30)
                
                Button(action: onAddTask) {
                    Label("Add New Task", systemImage: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .accessibilityLabel("Add New Task")
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .transition(.opacity)

    }
}

#Preview {
    TaskListView()
}
