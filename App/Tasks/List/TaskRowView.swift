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

            VStack(alignment: .leading, spacing: 4) {
                Text(task.content)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                HStack(spacing: 8) {
                    if let date = task.date {
                        Label(date.formatted(style: .taskRow), systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(date.isPast && !task.isCompleted ? .red : .secondary)
                    }

                    if task.taskPriority != .none {
                        Label(task.taskPriority.displayName, systemImage: task.taskPriority.systemImage)
                            .font(.caption)
                            .foregroundStyle(task.taskPriority.color)
                    }

                    let commentCount = task.activeComments.count
                    if commentCount > 0 {
                        Label("\(commentCount)", systemImage: "bubble.left")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    let reminderCount = task.activeReminders.count
                    if reminderCount > 0 {
                        Label("\(reminderCount)", systemImage: "bell")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
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
}
