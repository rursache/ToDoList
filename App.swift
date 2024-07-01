//
//  ToDoListApp.swift
//  ToDoList
//
//  Created by Radu Ursache on 01.07.2024.
//

import SwiftUI
import SwiftData

@main
struct ToDoListApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    private let sharedModelContainer: ModelContainer
    
    init() {
        self.sharedModelContainer = DatabaseManager.defaultModelContainer
    }

    var body: some Scene {
        WindowGroup {
            TaskView()
        }.modelContainer(sharedModelContainer)
    }
}
