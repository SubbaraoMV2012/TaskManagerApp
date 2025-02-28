//
//  TaskListViewModel.swift
//  TaskManagerApp
//
//  Created by SubbaRao MV on 27/02/25.
//

import Foundation
import SwiftUI
import Combine

enum SortOption {
    case byPriority, byDueDate, byAlphabetically
}

class TaskListViewModel: ObservableObject {
    @Published var filterStatus: TaskStatus?
    @Published var sortOption: SortOption = .byAlphabetically
    @Published var showUndoSnackbar = false
    @Published var isDeleteUndo = false
    
    private let database: DataBaseManagerProtocol
    private var recentlyDeletedTask: TaskModel?
    private var recentlyCompletedTask: TaskModel?
    @Published private(set) var tasks: [TaskModel] = []
    
    @Published var accentColor: Color = .blue
    @ObservedObject var settingsViewModel = SettingsViewModel.shared
    var cancellables: Set<AnyCancellable> = []
    @Published var snackbarMessage: String = ""
    
    var completionPercentage: Double {
        let totalTasks = tasks.count
        let completedTasks = tasks.filter { $0.status == .completed }.count
        return totalTasks == 0 ? 0 : (Double(completedTasks) / Double(totalTasks)) * 100
    }
    
    init(database: DataBaseManagerProtocol = DataBaseManager.shared) {
        self.database = database
        self.accentColor = settingsViewModel.selectedAccentColor.color
        
        settingsViewModel.$selectedAccentColor
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newColor in
                self?.accentColor = newColor.color
            }
            .store(in: &cancellables)
    }
    
    func updateTasks(_ fetchedTasks: FetchedResults<TaskEntity>) {
        DispatchQueue.main.async {
            let mappedTasks = fetchedTasks.map { entity in
                TaskModel(
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "",
                    taskDescription: entity.taskDescription,
                    priority: TaskPriority(rawValue: entity.priority ?? "low") ?? .low,
                    dueDate: entity.dueDate ?? Date(),
                    status: TaskStatus(rawValue: entity.status ?? "pending") ?? .pending,
                    sortIndex: Int(entity.sortIndex)
                )
            }
            self.tasks = self.sortAndFilterTasks(mappedTasks) // Ensure tasks get updated
        }
    }
    
    func addTask(_ task: TaskModel) {
        database.saveTask(task)
    }
    
    func deleteTask(task: TaskModel) {
        recentlyDeletedTask = task
        database.deleteTask(task)
        tasks.removeAll { $0.id == task.id }
        snackbarMessage = "Task deleted successfully!"
        self.tasks = self.sortAndFilterTasks(tasks)
        isDeleteUndo = true
        showUndoSnackbar = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.showUndoSnackbar = false
        }
    }
    
    func undoDeletedTask() {
        if let task = recentlyDeletedTask {
            database.saveTask(task)
            recentlyDeletedTask = nil
            let updatedTasks = database.fetchTasks()
            self.tasks = self.sortAndFilterTasks(updatedTasks)
            isDeleteUndo = false
            showUndoSnackbar = false
        }
    }
    
    func toggleTaskStatus(task: TaskModel) {
        recentlyCompletedTask = task
        isDeleteUndo = false
        let updatedTask = task.copyWith(status: task.status == .pending ? .completed : .pending)
        snackbarMessage = "Task status upated successfully!"
        database.updateTask(updatedTask)
        let updatedTasks = database.fetchTasks()
        self.tasks = self.sortAndFilterTasks(updatedTasks)
        showUndoSnackbar = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showUndoSnackbar = false
        }
    }
    
    func undoTaskStatus() {
        if let task = recentlyCompletedTask {
            let previousStatus: TaskStatus = task.status == .completed ? .pending : .completed
            let updatedTask = task.copyWith(status: previousStatus)
            
            database.updateTask(updatedTask)
            
            let updatedTasks = database.fetchTasks()
            self.tasks = self.sortAndFilterTasks(updatedTasks)
            
            recentlyCompletedTask = nil
            showUndoSnackbar = false
        }
    }
    
    private func sortAndFilterTasks(_ tasks: [TaskModel]) -> [TaskModel] {
        var filteredTasks = tasks
        if let status = filterStatus {
            filteredTasks = filteredTasks.filter { $0.status == status }
        }
        
        return switch sortOption {
        case .byPriority:
            filteredTasks.sorted { $0.priority.rawValue > $1.priority.rawValue }
        case .byDueDate:
            filteredTasks.sorted { $0.dueDate < $1.dueDate }
        case .byAlphabetically:
            filteredTasks.sorted { $0.title.localizedLowercase < $1.title.localizedLowercase }
        }
    }
    
    func moveTask(from source: IndexSet, to destination: Int) {
        var tasksArray = tasks
        tasksArray.move(fromOffsets: source, toOffset: destination)
        
        for (index, task) in tasksArray.enumerated() {
            let updatedTask = task.copyWith(sortIndex: index)
            database.updateTask(updatedTask)
        }
        self.tasks = self.sortAndFilterTasks(tasksArray)
    }
}

