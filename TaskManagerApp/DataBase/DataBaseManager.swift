//
//  DataBaseManager.swift
//  TaskManagerApp
//
//  Created by SubbaRao MV on 27/02/25.
//

import CoreData

protocol DataBaseManagerProtocol {
    func saveTask(_ task: TaskModel)
    func fetchTasks() -> [TaskModel]
    func updateTask(_ task: TaskModel)
    func deleteTask(_ task: TaskModel)
}

final class DataBaseManager: ObservableObject, DataBaseManagerProtocol {
    static let shared = DataBaseManager()
    private let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "TaskManagerApp")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    func saveTask(_ task: TaskModel) {
        let newTask = TaskEntity(context: context)
        newTask.id = task.id
        newTask.title = task.title
        newTask.taskDescription = task.taskDescription
        newTask.priority = task.priority.rawValue
        newTask.dueDate = task.dueDate
        newTask.status = task.status.rawValue
        newTask.sortIndex = Int64(task.sortIndex)

        saveContext()
    }

    func fetchTasks() -> [TaskModel] {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.sortIndex, ascending: true)]

        do {
            let taskEntities = try context.fetch(request)
            return taskEntities.map { entity in
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
        } catch {
            print("Error fetching tasks: \(error.localizedDescription)")
            return []
        }
    }

    
    func updateTask(_ task: TaskModel) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
        
        do {
            let tasks = try context.fetch(request)
            if let taskEntity = tasks.first {
                taskEntity.title = task.title
                taskEntity.taskDescription = task.taskDescription
                taskEntity.priority = task.priority.rawValue
                taskEntity.dueDate = task.dueDate
                taskEntity.status = task.status.rawValue
                saveContext()
            }
        } catch {
            print("Failed to update task: \(error.localizedDescription)")
        }
    }
    
    func deleteTask(_ task: TaskModel) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
        
        do {
            let tasks = try context.fetch(request)
            if let taskEntity = tasks.first {
                context.delete(taskEntity)
                saveContext()
            }
        } catch {
            print("Failed to delete task: \(error.localizedDescription)")
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save Core Data context: \(error.localizedDescription)")
        }
    }
}
