//
//  TaskCreationViewModel.swift
//  TaskManagerApp
//
//  Created by SubbaRao MV on 27/02/25.
//

import Foundation

@Observable
final class TaskCreationViewModel {
    var title: String = ""
    var description: String = ""
    var priority: TaskPriority = .low
    var dueDate: Date = .now
    
    private let database: DataBaseManagerProtocol
    var onTaskAdded: ((TaskModel) -> Void)?
    
    init(database: DataBaseManagerProtocol = DataBaseManager.shared, onTaskAdded: ((TaskModel) -> Void)? = nil) {
        self.database = database
        self.onTaskAdded = onTaskAdded
    }
    
    func saveTask() {
        let existingTasks = database.fetchTasks()
        guard !title.isEmpty else { return }
        let newTask = TaskModel(id: UUID(), title: title, taskDescription: description, priority: priority, dueDate: dueDate, status: .pending, sortIndex: existingTasks.isEmpty ? 0 : existingTasks.count)
        database.saveTask(newTask)
        onTaskAdded?(newTask)
    }
}
