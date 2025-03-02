//
//  TaskManagerAppUITests.swift
//  TaskManagerAppUITests
//
//  Created by SubbaRao MV on 27/02/25.
//

import XCTest

final class TaskManagerAppUITests: XCTestCase {
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }
    
    func testAddNewTask() throws {
        let addButton = app.buttons["AddTaskButton"]
        
        XCTAssertTrue(addButton.waitForExistence(timeout: 5), "Add Task button did not appear in time.")
        
        if !addButton.isHittable {
            app.swipeUp()
        }
        
        XCTAssertTrue(addButton.isHittable, "Add Task button is still not accessible after scrolling.")
        addButton.tap()
        
        let titleField = app.textFields["Task title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3), "Task Title field is missing.")
        
        titleField.tap()
        titleField.typeText("New Task")
        
        let saveButton = app.buttons["Save Task"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3), "Save button is missing.")
        saveButton.tap()
        
        XCTAssertTrue(app.staticTexts["New Task"].waitForExistence(timeout: 3), "Newly added task is not visible.")
    }
    
    func testSortAndFilterTasks() throws {
        let sortButton = app.buttons["Sort tasks-Filter tasks"]
        XCTAssertTrue(sortButton.waitForExistence(timeout: 5), "Sort & Filter button did not appear in time.")
        
        sortButton.tap()
        
        let alphabeticalSortButton = app.buttons["Alphabetically"]
        XCTAssertTrue(alphabeticalSortButton.waitForExistence(timeout: 3), "Alphabetically sort button is missing.")
        
        alphabeticalSortButton.tap()
        
        sleep(1)
        
        let taskElements = app.staticTexts.matching(identifier: "TaskTitle")
        var taskNames: [String] = []
        
        for i in 0..<taskElements.count {
            let taskName = taskElements.element(boundBy: i).label.trimmingCharacters(in: .whitespacesAndNewlines)
            taskNames.append(taskName)
        }
        
        let sortedTaskNames = taskNames.sorted()
        XCTAssertEqual(taskNames, sortedTaskNames, "Tasks are not sorted alphabetically.")
        
        let filterButton = app.buttons["All"]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 3), "Filter button is missing.")
        
        if !filterButton.isHittable {
            app.swipeUp()
        }
        filterButton.tap()
        
        let completedFilterButton = app.buttons["Completed"]
        XCTAssertTrue(completedFilterButton.waitForExistence(timeout: 3), "Completed filter option is missing.")
        
        completedFilterButton.tap()
    }


    func testAccessibilityElements() {
        let addPulseButton = app.buttons["Add Task"]

        XCTAssertTrue(addPulseButton.waitForExistence(timeout: 5), "Add task pulse button is missing.")
    }
}
