//
//  TaskManagerAppApp.swift
//  TaskManagerApp
//
//  Created by SubbaRao MV on 27/02/25.
//

import SwiftUI

@main
struct TaskManagerAppApp: App {
    let dataBaseManager = DataBaseManager.shared

    var body: some Scene {
        WindowGroup {
            TaskListView()
                .environment(\.managedObjectContext, dataBaseManager.context)

        }
    }
}
