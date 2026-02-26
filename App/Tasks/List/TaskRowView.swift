//
//  TaskRowView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct TaskRowView: View {
    @Bindable var task: TaskModel
    @State private var showingEdit = false

    var body: some View {
        HStack(spacing: 12) {
            CheckButtonView(checked: $task.isCompleted)
                .onChange(of: task.isCompleted) { _, newValue in
                    task.completedDate = newValue ? Date() : nil
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(task.content)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                if !task.taskDescription.isEmpty {
                    Text(task.taskDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                if hasMetadata {
                    HStack(spacing: 6) {
                        if let date = task.date {
                            let isOverdue = task.hasTime ? date.isPast : date.isPastDay
                            metadataTag(
                                systemImage: "calendar",
                                text: date.formatted(style: .taskRow, hasTime: task.hasTime),
                                color: isOverdue && !task.isCompleted ? .red : .secondary
                            )
                        }

                        if task.taskPriority != .none {
                            metadataTag(
                                systemImage: task.taskPriority.systemImage,
                                text: task.taskPriority.displayName,
                                color: task.taskPriority.color
                            )
                        }

                        let commentCount = task.activeComments.count
                        if commentCount > 0 {
                            metadataTag(
                                systemImage: "bubble.left",
                                text: "\(commentCount)",
                                color: .secondary
                            )
                        }

                        let reminderCount = task.activeReminders.count
                        if reminderCount > 0 {
                            metadataTag(
                                systemImage: "bell",
                                text: "\(reminderCount)",
                                color: .secondary
                            )
                        }
                    }
                    .padding(.top, 1)
                }
            }

            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showingEdit = true
        }
        .sheet(isPresented: $showingEdit) {
            TaskEditView(task: task)
        }
        .contextMenu {
            Button {
                showingEdit = true
            } label: {
                Label(String(localized: "edit", defaultValue: "Edit"), systemImage: "pencil")
            }

            Button {
                task.isCompleted.toggle()
                task.completedDate = task.isCompleted ? Date() : nil
            } label: {
                Label(
                    task.isCompleted ? String(localized: "uncomplete", defaultValue: "Mark Incomplete") : String(localized: "complete", defaultValue: "Mark Complete"),
                    systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark"
                )
            }

            Divider()

            Button(role: .destructive) {
                task.isDeleted = true
            } label: {
                Label(String(localized: "delete", defaultValue: "Delete"), systemImage: "trash")
            }
        }
    }

    private var hasMetadata: Bool {
        task.date != nil || task.taskPriority != .none || task.activeComments.count > 0 || task.activeReminders.count > 0
    }

    private func metadataTag(systemImage: String, text: String, color: Color) -> some View {
        HStack(spacing: 2) {
            Image(systemName: systemImage)
            Text(text)
        }
        .font(.caption)
        .foregroundStyle(color)
    }
}

#Preview {
    List {
        TaskRowView(task: TaskModel.sampleTasks.first!)
    }
    .modelContainer(DatabaseConfiguration.makePreviewContainer())
    .environment(AppSettings.shared)
}
