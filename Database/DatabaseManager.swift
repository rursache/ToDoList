//
//  DatabaseActor.swift
//  ToDoList
//
//  Created by Radu Ursache on 01.07.2024.
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import Foundation
import SwiftData

class DatabaseManager {
    static let shared = DatabaseManager()
    
    
}

/// MARK: Tasks
extension DatabaseManager {
    func insert(_ task: TaskModel, in container: ModelContainer) {
        Task {
            try await DatabaseActor<TaskModel>(modelContainer: container).insert(task)
        }
    }
    
    func delete(_ task: TaskModel, in container: ModelContainer) {
        Task {
            try await DatabaseActor<TaskModel>(modelContainer: container).delete(task)
        }
    }
    
    func delete(_ taskId: PersistentIdentifier, in container: ModelContainer) {
        Task {
            try await DatabaseActor<TaskModel>(modelContainer: container).delete(taskId)
        }
    }
    
    func delete(_ taskIds: [PersistentIdentifier], in container: ModelContainer) {
        Task {
            try await DatabaseActor<TaskModel>(modelContainer: container).delete(taskIds)
        }
    }
}

/// MARK: Mocks
extension DatabaseManager {
    func insertMockData(_ container: ModelContainer, force: Bool = false) {
        Task {
            let taskCount = try await DatabaseActor<TaskModel>(modelContainer: container).fetch().count
            
            if taskCount == 0 || force == true {
                try await DatabaseActor<TaskModel>(modelContainer: container).insert(TaskModel.mocks)
            }
        }
    }
}

extension DatabaseManager {
    static var defaultSchema: Schema {
        return Schema([
            ItemModel.self, TaskModel.self
        ])
    }
    
    @MainActor
    static var defaultModelContainer: ModelContainer {
        do {
            let defaultContainer = try ModelContainer(for: DatabaseManager.defaultSchema, configurations: ModelConfiguration(isStoredInMemoryOnly: false))
            
            DatabaseManager.shared.insertMockData(defaultContainer)
            
            return defaultContainer
        } catch {
            fatalError("Failed to get default model container")
        }
    }
    
    @MainActor
    static var simulatorModelContainer: ModelContainer {
        do {
            let simulatorContainer = try ModelContainer(for: DatabaseManager.defaultSchema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
            
            DatabaseManager.shared.insertMockData(simulatorContainer)
            
            return simulatorContainer
        } catch {
            fatalError("Failed to get simulator model container")
        }
    }
}
