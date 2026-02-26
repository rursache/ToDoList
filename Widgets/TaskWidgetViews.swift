//
//  TaskWidgetViews.swift
//  Widgets
//
//  Copyright © 2026 RanduSoft. All rights reserved.
//

import SwiftUI
import WidgetKit

struct TaskWidgetEntryView: View {
    var entry: TaskWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        case .systemExtraLarge:
            ExtraLargeWidgetView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}

// MARK: - Header

private struct WidgetHeader: View {
    let filter: TaskWidgetFilter
    let taskCount: Int
    let themeColor: Color

    var body: some View {
        HStack {
            Image(systemName: filter.systemImage)
                .font(.headline)
                .foregroundStyle(themeColor)
            Text(filter.displayName)
                .font(.headline)
                .fontWeight(.bold)
            Spacer()
            Text("\(taskCount)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Task Row

private struct TaskRowCompact: View {
    let task: TaskWidgetItem

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(task.priorityColor)
                .frame(width: 8, height: 8)
            Text(task.content)
                .font(.caption)
                .lineLimit(1)
            Spacer()
        }
    }
}

private struct TaskRowMedium: View {
    let task: TaskWidgetItem

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(task.priorityColor)
                .frame(width: 8, height: 8)
            Text(task.content)
                .font(.caption)
                .lineLimit(1)
            Spacer()
            if !task.dateString.isEmpty {
                Text(task.dateString)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct TaskRowLarge: View {
    let task: TaskWidgetItem

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(task.priorityColor)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 1) {
                Text(task.content)
                    .font(.caption)
                    .lineLimit(1)
                if !task.taskDescription.isEmpty {
                    Text(task.taskDescription)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            if !task.dateString.isEmpty {
                Text(task.dateString)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Empty State

private struct EmptyStateView: View {
    let filter: TaskWidgetFilter

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "checkmark.circle")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No \(filter.displayName.lowercased()) tasks")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Small

struct SmallWidgetView: View {
    let entry: TaskWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            WidgetHeader(filter: entry.filter, taskCount: entry.tasks.count, themeColor: entry.themeColor)

            if entry.tasks.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    EmptyStateView(filter: entry.filter)
                    Spacer()
                }
                Spacer()
            } else {
                ForEach(entry.tasks.prefix(3), id: \.id) { task in
                    TaskRowCompact(task: task)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

// MARK: - Medium

struct MediumWidgetView: View {
    let entry: TaskWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            WidgetHeader(filter: entry.filter, taskCount: entry.tasks.count, themeColor: entry.themeColor)

            if entry.tasks.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    EmptyStateView(filter: entry.filter)
                    Spacer()
                }
                Spacer()
            } else {
                ForEach(entry.tasks.prefix(4), id: \.id) { task in
                    TaskRowMedium(task: task)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

// MARK: - Large

struct LargeWidgetView: View {
    let entry: TaskWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            WidgetHeader(filter: entry.filter, taskCount: entry.tasks.count, themeColor: entry.themeColor)

            if entry.tasks.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    EmptyStateView(filter: entry.filter)
                    Spacer()
                }
                Spacer()
            } else {
                ForEach(entry.tasks.prefix(8), id: \.id) { task in
                    TaskRowLarge(task: task)
                    if task.id != entry.tasks.prefix(8).last?.id {
                        Divider()
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }
}

// MARK: - Extra Large

struct ExtraLargeWidgetView: View {
    let entry: TaskWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            WidgetHeader(filter: entry.filter, taskCount: entry.tasks.count, themeColor: entry.themeColor)

            if entry.tasks.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    EmptyStateView(filter: entry.filter)
                    Spacer()
                }
                Spacer()
            } else {
                ForEach(entry.tasks.prefix(12), id: \.id) { task in
                    TaskRowLarge(task: task)
                    if task.id != entry.tasks.prefix(12).last?.id {
                        Divider()
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    TaskWidget()
} timeline: {
    TaskWidgetEntry(date: .now, tasks: [
        TaskWidgetItem(id: UUID(), content: "Buy groceries", taskDescription: "", priorityColor: .orange, dateString: "10:00 AM", isCompleted: false),
        TaskWidgetItem(id: UUID(), content: "Review PR", taskDescription: "", priorityColor: .red, dateString: "2:00 PM", isCompleted: false),
        TaskWidgetItem(id: UUID(), content: "Call dentist", taskDescription: "", priorityColor: .yellow, dateString: "4:00 PM", isCompleted: false),
    ], filter: .today, themeColor: AppTheme.red.color)
}

#Preview(as: .systemMedium) {
    TaskWidget()
} timeline: {
    TaskWidgetEntry(date: .now, tasks: [
        TaskWidgetItem(id: UUID(), content: "Buy groceries", taskDescription: "", priorityColor: .orange, dateString: "10:00 AM", isCompleted: false),
        TaskWidgetItem(id: UUID(), content: "Review PR", taskDescription: "Check the new auth module", priorityColor: .red, dateString: "2:00 PM", isCompleted: false),
        TaskWidgetItem(id: UUID(), content: "Call dentist", taskDescription: "", priorityColor: .yellow, dateString: "4:00 PM", isCompleted: false),
        TaskWidgetItem(id: UUID(), content: "Plan weekend trip", taskDescription: "", priorityColor: .green, dateString: "Tomorrow", isCompleted: false),
    ], filter: .upcoming, themeColor: AppTheme.blue.color)
}

#Preview(as: .systemSmall) {
    TaskWidget()
} timeline: {
    TaskWidgetEntry(date: .now, tasks: [], filter: .today, themeColor: AppTheme.red.color)
}
