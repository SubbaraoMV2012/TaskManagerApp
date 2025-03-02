//
//  TaskManagerAppTests.swift
//  TaskManagerAppTests
//
//  Created by SubbaRao MV on 27/02/25.
//

import XCTest
import SnapshotTesting
import SwiftUI

@testable import TaskManagerApp

class TaskManagerAppTests: XCTestCase {
    
    override func setUpWithError() throws {
    }

    func testTaskListLightMode() {
        let view = TaskListView()
        let container = UIHostingController(rootView: view)

        assertSnapshot(of: container, as: .image(on: .iPhone13))
    }
    
    func testTaskListDarkMode() {
        let view = TaskListView()
        let container = UIHostingController(rootView: view)
        
        container.overrideUserInterfaceStyle = .dark
        
        assertSnapshot(of: container, as: .image(on: .iPhone13))
    }
    
    func testTaskDetailsLightMode() {
        let view = TaskDetailView(
            task: .constant(SampleTask.mockTask),
            viewModel: TaskDetailViewModel(task: SampleTask.mockTask)
        )
        let container = UIHostingController(rootView: view)
        
        assertSnapshot(of: container, as: .image(on: .iPhone13))
    }
    
    func testTaskDetailsDarkMode() {
        let view = TaskDetailView(
            task: .constant(SampleTask.mockTask),
            viewModel: TaskDetailViewModel(task: SampleTask.mockTask)
        )
        let container = UIHostingController(rootView: view)
        
        container.overrideUserInterfaceStyle = .dark
        
        assertSnapshot(of: container, as: .image(on: .iPhone13))
    }
}

struct SampleTask {
    static let mockTask = TaskModel(
        id: UUID(),
        title: "Mock Task",
        taskDescription: "This is a sample task",
        priority: .low,
        dueDate: Date(),
        status: .pending,
        sortIndex: 0
    )
}
