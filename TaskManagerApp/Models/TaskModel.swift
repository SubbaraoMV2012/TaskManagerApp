//
//  TaskModel.swift
//  TaskManagerApp
//
//  Created by SubbaRao MV on 27/02/25.
//

import Foundation
import CoreData

enum TaskPriority: String, CaseIterable {
    case low, medium, high
}

enum TaskStatus: String, CaseIterable {
    case pending, completed
}

struct TaskModel: Identifiable, Equatable {
    let id: UUID
    var title: String
    var taskDescription: String?
    var priority: TaskPriority
    var dueDate: Date
    var status: TaskStatus
    var sortIndex: Int
    
    static func == (lhs: TaskModel, rhs: TaskModel) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.taskDescription == rhs.taskDescription &&
        lhs.priority == rhs.priority &&
        lhs.dueDate == rhs.dueDate &&
        lhs.status == rhs.status
    }
    
    func copyWith(
        id: UUID? = nil,
        title: String? = nil,
        taskDescription: String? = nil,
        priority: TaskPriority? = nil,
        dueDate: Date? = nil,
        status: TaskStatus? = nil,
        sortIndex: Int? = nil
    ) -> TaskModel {
        return TaskModel(
            id: id ?? self.id,
            title: title ?? self.title,
            taskDescription: taskDescription ?? self.taskDescription,
            priority: priority ?? self.priority,
            dueDate: dueDate ?? self.dueDate,
            status: status ?? self.status,
            sortIndex: sortIndex ?? self.sortIndex
        )
    }
}
