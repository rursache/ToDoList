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
    static func seedDemoData(into context: ModelContext) {
        // Delete all existing data
        try? context.delete(model: ReminderModel.self)
        try? context.delete(model: CommentModel.self)
        try? context.delete(model: TaskModel.self)

        for (index, task) in TaskModel.demoTasks.enumerated() {
            task.sortOrder = index
            context.insert(task)
        }

        try? context.save()
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
        Array(demoTasks.prefix(6))
    }

    static var demoTasks: [TaskModel] {
        let calendar = Calendar.current
        let now = Date()

        func date(byAdding component: Calendar.Component, value: Int, hour: Int? = nil, minute: Int? = nil) -> Date? {
            var result = calendar.date(byAdding: component, value: value, to: now)!
            if let hour, let minute {
                result = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: result)!
            }
            return result
        }

        return [
            // Today tasks with time
            {
                let t = TaskModel(content: "Buy groceries", taskDescription: "Milk, eggs, bread, avocados, chicken", date: date(byAdding: .hour, value: 2, hour: nil, minute: nil), priority: TaskPriority.high.rawValue)
                t.hasTime = true
                return t
            }(),
            {
                let t = TaskModel(content: "Team standup meeting", date: date(byAdding: .hour, value: 3, hour: nil, minute: nil), priority: TaskPriority.highest.rawValue)
                t.hasTime = true
                return t
            }(),
            {
                let t = TaskModel(content: "Reply to Sarah's email", date: calendar.startOfDay(for: now), priority: TaskPriority.normal.rawValue)
                return t
            }(),

            // Tomorrow
            {
                let t = TaskModel(content: "Call dentist", taskDescription: "Schedule cleaning appointment", date: date(byAdding: .day, value: 1, hour: 10, minute: 0), priority: TaskPriority.normal.rawValue)
                t.hasTime = true
                return t
            }(),
            {
                let t = TaskModel(content: "Submit expense report", date: date(byAdding: .day, value: 1), priority: TaskPriority.high.rawValue)
                return t
            }(),

            // This week
            {
                let t = TaskModel(content: "Plan weekend trip", taskDescription: "Look into cabin rentals near the mountains", date: date(byAdding: .day, value: 3), priority: TaskPriority.low.rawValue)
                return t
            }(),
            {
                let t = TaskModel(content: "Renew gym membership", date: date(byAdding: .day, value: 4, hour: 18, minute: 0), priority: TaskPriority.normal.rawValue)
                t.hasTime = true
                return t
            }(),
            {
                let t = TaskModel(content: "Read Swift concurrency chapter", taskDescription: "Chapters 5–7 in the Swift book")
                return t
            }(),
            {
                let t = TaskModel(content: "Fix leaking kitchen faucet", date: date(byAdding: .day, value: 5), priority: TaskPriority.high.rawValue)
                return t
            }(),

            // Next week
            {
                let t = TaskModel(content: "Prepare presentation slides", taskDescription: "Q1 review for the team meeting", date: date(byAdding: .day, value: 7, hour: 9, minute: 30), priority: TaskPriority.highest.rawValue)
                t.hasTime = true
                return t
            }(),
            {
                let t = TaskModel(content: "Water the plants", date: date(byAdding: .day, value: 8), priority: TaskPriority.low.rawValue)
                return t
            }(),

            // Completed
            {
                let t = TaskModel(content: "Review pull request", date: date(byAdding: .hour, value: -3, hour: nil, minute: nil), priority: TaskPriority.highest.rawValue)
                t.hasTime = true
                t.isCompleted = true
                t.completedDate = now
                return t
            }(),
            {
                let t = TaskModel(content: "Order new headphones", date: calendar.date(byAdding: .day, value: -1, to: now), priority: TaskPriority.normal.rawValue)
                t.isCompleted = true
                t.completedDate = calendar.date(byAdding: .day, value: -1, to: now)
                return t
            }(),
            {
                let t = TaskModel(content: "Pay electricity bill", date: calendar.date(byAdding: .day, value: -2, to: now), priority: TaskPriority.high.rawValue)
                t.isCompleted = true
                t.completedDate = calendar.date(byAdding: .day, value: -2, to: now)
                return t
            }(),
        ]
    }
}
