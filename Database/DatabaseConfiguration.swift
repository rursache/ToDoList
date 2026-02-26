//
//  DatabaseConfiguration.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import Foundation
import SwiftData

struct DatabaseConfiguration {
    static let appGroupId = "group.ro.randusoft.RSToDoList"

    static let schema = Schema([
        TaskModel.self,
        CommentModel.self,
        ReminderModel.self
    ])

    @MainActor
    static func makeContainer() -> ModelContainer {
        let bundleId = Bundle.main.bundleIdentifier!

        let configuration = ModelConfiguration(
            "ToDoList",
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            groupContainer: .identifier(appGroupId),
            cloudKitDatabase: .private("iCloud.\(bundleId)")
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    static func makeWidgetContainer() -> ModelContainer {
        let configuration = ModelConfiguration(
            "ToDoList",
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: false,
            groupContainer: .identifier(appGroupId),
            cloudKitDatabase: .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create widget ModelContainer: \(error)")
        }
    }

    @MainActor
    static func makePreviewContainer() -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let context = container.mainContext

            for task in TaskModel.sampleTasks {
                context.insert(task)
            }

            return container
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error)")
        }
    }
}

extension TaskModel {
    static var sampleTasks: [TaskModel] {
        let calendar = Calendar.current
        let now = Date()

        return [
            {
                let t = TaskModel(content: "Buy groceries", date: calendar.date(byAdding: .hour, value: 2, to: now), priority: TaskPriority.high.rawValue)
                return t
            }(),
            {
                let t = TaskModel(content: "Review pull request", date: calendar.date(byAdding: .hour, value: 4, to: now), priority: TaskPriority.highest.rawValue)
                return t
            }(),
            {
                let t = TaskModel(content: "Call dentist", date: calendar.date(byAdding: .day, value: 1, to: now), priority: TaskPriority.normal.rawValue)
                return t
            }(),
            {
                let t = TaskModel(content: "Plan weekend trip", date: calendar.date(byAdding: .day, value: 3, to: now), priority: TaskPriority.low.rawValue)
                return t
            }(),
            {
                let t = TaskModel(content: "Read Swift concurrency chapter")
                return t
            }(),
            {
                let t = TaskModel(content: "Completed task example", date: calendar.date(byAdding: .hour, value: -3, to: now), priority: TaskPriority.normal.rawValue)
                t.isCompleted = true
                t.completedDate = now
                return t
            }(),
        ]
    }
}
