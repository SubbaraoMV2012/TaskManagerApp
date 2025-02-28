//
//  TaskDetailViewModel.swift
//  TaskManagerApp
//
//  Created by SubbaRao MV on 27/02/25.
//

import Foundation

final class TaskDetailViewModel: ObservableObject {
    @Published var task: TaskModel
    
    private let dataBaseManagerProtocol: DataBaseManagerProtocol
    var onTaskDeleted: (() -> Void)?
    var onTaskUpdated: (() -> Void)?
    
    init(task: TaskModel,
         dataBaseManagerProtocol: DataBaseManagerProtocol = DataBaseManager.shared,
         onTaskDeleted: (() -> Void)? = nil,
         onTaskUpdated: (() -> Void)? = nil
    ) {
        self.task = task
        self.dataBaseManagerProtocol = dataBaseManagerProtocol
        self.onTaskDeleted = onTaskDeleted
        self.onTaskUpdated = onTaskUpdated
    }
    
    func toggleCompletion() {
        task.status = .completed
        dataBaseManagerProtocol.updateTask(task)
        DispatchQueue.main.async {
            self.onTaskUpdated?()
        }
    }
    
    func deleteTask() {
        dataBaseManagerProtocol.deleteTask(task)
        DispatchQueue.main.async {
            self.onTaskDeleted?()
        }
    }
}
