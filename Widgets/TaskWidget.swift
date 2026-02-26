//
//  TaskWidget.swift
//  Widgets
//
//  Copyright © 2026 RanduSoft. All rights reserved.
//

import WidgetKit
import SwiftUI
import SwiftData

struct TaskWidgetItem {
    let id: UUID
    let content: String
    let taskDescription: String
    let priorityColor: Color
    let priorityName: String
    let dateString: String
    let isCompleted: Bool
}

struct TaskWidgetEntry: TimelineEntry {
    let date: Date
    let tasks: [TaskWidgetItem]
    let filter: TaskWidgetFilter
    let themeColor: Color
}

struct TaskWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> TaskWidgetEntry {
        TaskWidgetEntry(
            date: .now,
            tasks: [
                TaskWidgetItem(id: UUID(), content: "Sample task", taskDescription: "", priorityColor: .orange, priorityName: "High", dateString: "10:00 AM", isCompleted: false),
                TaskWidgetItem(id: UUID(), content: "Another task", taskDescription: "", priorityColor: .red, priorityName: "Highest", dateString: "2:00 PM", isCompleted: false)
            ],
            filter: .today,
            themeColor: Self.readThemeColor()
        )
    }

    func snapshot(for configuration: TaskWidgetIntent, in context: Context) async -> TaskWidgetEntry {
        await fetchEntry(for: configuration, family: context.family)
    }

    func timeline(for configuration: TaskWidgetIntent, in context: Context) async -> Timeline<TaskWidgetEntry> {
        let entry = await fetchEntry(for: configuration, family: context.family)
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        return Timeline(entries: [entry], policy: .after(refreshDate))
    }

    @MainActor
    private func fetchEntry(for configuration: TaskWidgetIntent, family: WidgetFamily) -> TaskWidgetEntry {
        let filter = configuration.filter
        let limit = taskLimit(for: family)

        do {
            let container = DatabaseConfiguration.makeWidgetContainer()
            let context = container.mainContext

            let calendar = Calendar.current
            let now = Date()
            let startOfToday = calendar.startOfDay(for: now)

            let descriptor = FetchDescriptor<TaskModel>(
                predicate: #Predicate<TaskModel> { task in
                    !task.isCompleted && !task.isDeleted
                },
                sortBy: [SortDescriptor(\.date, order: .forward)]
            )

            let allTasks = try context.fetch(descriptor)

            let filteredTasks: [TaskModel]
            switch filter {
            case .today:
                let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
                filteredTasks = allTasks.filter { task in
                    guard let date = task.date else { return false }
                    return date >= startOfToday && date < endOfToday
                }
            case .upcoming:
                filteredTasks = allTasks.filter { task in
                    guard let date = task.date else { return false }
                    return date >= startOfToday
                }
            }

            let limitedTasks = Array(filteredTasks.prefix(limit))

            let timeFormatter = DateFormatter()
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = .short

            let dateTimeFormatter = DateFormatter()
            dateTimeFormatter.dateStyle = .short
            dateTimeFormatter.timeStyle = .short

            let dateOnlyFormatter = DateFormatter()
            dateOnlyFormatter.dateStyle = .short
            dateOnlyFormatter.timeStyle = .none

            let items = limitedTasks.map { task in
                let priority = TaskPriority(rawValue: task.priority) ?? .none
                let dateStr: String
                if let date = task.date {
                    let todayStr = String(localized: "dateToday", defaultValue: "Today")
                    let tomorrowStr = String(localized: "dateTomorrow", defaultValue: "Tomorrow")
                    if calendar.isDateInToday(date) {
                        dateStr = task.hasTime ? timeFormatter.string(from: date) : todayStr
                    } else if calendar.isDateInTomorrow(date) {
                        dateStr = task.hasTime ? "\(tomorrowStr), \(timeFormatter.string(from: date))" : tomorrowStr
                    } else {
                        dateStr = task.hasTime ? dateTimeFormatter.string(from: date) : dateOnlyFormatter.string(from: date)
                    }
                } else {
                    dateStr = ""
                }

                return TaskWidgetItem(
                    id: task.id,
                    content: task.content,
                    taskDescription: task.taskDescription,
                    priorityColor: priority.color,
                    priorityName: priority.displayName,
                    dateString: dateStr,
                    isCompleted: task.isCompleted
                )
            }

            return TaskWidgetEntry(date: now, tasks: items, filter: filter, themeColor: Self.readThemeColor())
        } catch {
            return TaskWidgetEntry(date: .now, tasks: [], filter: filter, themeColor: Self.readThemeColor())
        }
    }

    private static func readThemeColor() -> Color {
        let themeRaw = UserDefaults(suiteName: DatabaseConfiguration.appGroupId)?.integer(forKey: "selectedTheme") ?? 0
        return (AppTheme(rawValue: themeRaw) ?? .red).color
    }

    private func taskLimit(for family: WidgetFamily) -> Int {
        switch family {
        case .systemSmall: 3
        case .systemMedium: 4
        case .systemLarge: 8
        case .systemExtraLarge: 12
        default: 4
        }
    }
}

struct TaskWidget: Widget {
    let kind: String = "TaskWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: TaskWidgetIntent.self, provider: TaskWidgetProvider()) { entry in
            TaskWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(Text(LocalizedStringResource("widgetTasks", defaultValue: "Tasks")))
        .description(Text(LocalizedStringResource("widgetDescription", defaultValue: "View your today or upcoming tasks.")))
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}
