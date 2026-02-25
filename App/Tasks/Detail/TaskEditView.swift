//
//  TaskEditView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI
import SwiftData

struct TaskEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings

    var task: TaskModel?

    @State private var content: String = ""
    @State private var date: Date?
    @State private var showDatePicker = false
    @State private var priority: TaskPriority = .none
    @State private var showPriorityPicker = false
    @State private var showComments = false
    @State private var showReminders = false

    private var isNewTask: Bool { task == nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "taskContentPlaceholder", defaultValue: "What do you need to do?"), text: $content, axis: .vertical)
                        .lineLimit(1...5)
                }

                Section {
                    Button {
                        showDatePicker.toggle()
                    } label: {
                        HStack {
                            Label(String(localized: "dueDate", defaultValue: "Due Date"), systemImage: "calendar")
                            Spacer()
                            if let date {
                                Text(date.formatted(style: .taskRow))
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(String(localized: "none", defaultValue: "None"))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .tint(.primary)

                    if showDatePicker {
                        DatePicker(
                            String(localized: "selectDate", defaultValue: "Select date"),
                            selection: Binding(
                                get: { date ?? Date() },
                                set: { date = $0 }
                            ),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.graphical)

                        if date != nil {
                            Button(String(localized: "clearDate", defaultValue: "Clear Date"), role: .destructive) {
                                date = nil
                                showDatePicker = false
                            }
                        }
                    }
                }

                Section {
                    Button {
                        showPriorityPicker = true
                    } label: {
                        HStack {
                            Label(String(localized: "priority", defaultValue: "Priority"), systemImage: "flag")
                            Spacer()
                            if priority != .none {
                                Label(priority.displayName, systemImage: priority.systemImage)
                                    .foregroundStyle(priority.color)
                            } else {
                                Text(String(localized: "none", defaultValue: "None"))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .tint(.primary)
                }

                if let task {
                    Section {
                        Button {
                            showComments = true
                        } label: {
                            HStack {
                                Label(String(localized: "comments", defaultValue: "Comments"), systemImage: "bubble.left")
                                Spacer()
                                let count = task.activeComments.count
                                if count > 0 {
                                    Text("\(count)")
                                        .foregroundStyle(.secondary)
                                }
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(.primary)

                        Button {
                            showReminders = true
                        } label: {
                            HStack {
                                Label(String(localized: "reminders", defaultValue: "Reminders"), systemImage: "bell")
                                Spacer()
                                let count = task.activeReminders.count
                                if count > 0 {
                                    Text("\(count)")
                                        .foregroundStyle(.secondary)
                                }
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(.primary)
                    }
                }
            }
            .navigationTitle(isNewTask ? String(localized: "newTask", defaultValue: "New Task") : String(localized: "editTask", defaultValue: "Edit Task"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel", defaultValue: "Cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "save", defaultValue: "Save")) {
                        save()
                    }
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .confirmationDialog(
                String(localized: "selectPriority", defaultValue: "Select Priority"),
                isPresented: $showPriorityPicker,
                titleVisibility: .visible
            ) {
                ForEach(TaskPriority.allCases, id: \.self) { p in
                    Button(p.displayName) {
                        priority = p
                    }
                }
            }
            .onAppear {
                if let task {
                    content = task.content
                    date = task.date
                    priority = task.taskPriority
                }
            }
            .sheet(isPresented: $showComments) {
                if let task {
                    CommentsView(task: task)
                }
            }
            .sheet(isPresented: $showReminders) {
                if let task {
                    RemindersView(task: task)
                }
            }
        }
    }

    private func save() {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let task {
            task.content = trimmed
            task.date = date
            task.taskPriority = priority
        } else {
            let newTask = TaskModel(content: trimmed, date: date, priority: priority.rawValue)
            modelContext.insert(newTask)

            if !appSettings.disableAutoReminders, let taskDate = date, taskDate > Date() {
                let reminder = ReminderModel()
                reminder.text = String(localized: "autoReminder", defaultValue: "Task reminder")
                reminder.date = taskDate.addingTimeInterval(-30 * 60)
                reminder.task = newTask
                modelContext.insert(reminder)

                Task {
                    try? await NotificationManager.shared.scheduleReminder(for: newTask, reminder: reminder)
                }
            }
        }

        dismiss()
    }
}
