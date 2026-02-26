//
//  RemindersView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct RemindersView: View {
    @Bindable var task: TaskModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showingAddReminder = false
    @State private var newReminderDate = Date()
    @State private var newReminderText = ""

    private var activeReminders: [ReminderModel] {
        task.activeReminders.sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationStack {
            Group {
                if activeReminders.isEmpty {
                    ContentUnavailableView(
                        String(localized: "noReminders", defaultValue: "No reminders"),
                        systemImage: "bell",
                        description: Text(String(localized: "addReminderPrompt", defaultValue: "Tap + to add a reminder"))
                    )
                } else {
                    List {
                        ForEach(activeReminders) { reminder in
                            ReminderRowView(reminder: reminder)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        deleteReminder(reminder)
                                    } label: {
                                        Label(String(localized: "delete", defaultValue: "Delete"), systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "reminders", defaultValue: "Reminders"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "done", defaultValue: "Done")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        newReminderDate = task.date ?? Date().addingTimeInterval(3600)
                        newReminderText = ""
                        showingAddReminder = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                AddReminderSheet(
                    date: $newReminderDate,
                    text: $newReminderText,
                    onSave: addReminder
                )
            }
        }
    }

    private func addReminder() {
        let reminder = ReminderModel()
        reminder.text = newReminderText.isEmpty ? String(localized: "reminder", defaultValue: "Reminder") : newReminderText
        reminder.date = newReminderDate
        reminder.task = task
        modelContext.insert(reminder)

        let capturedTask = task
        Task {
            try? await NotificationManager.shared.scheduleReminder(for: capturedTask, reminder: reminder)
        }
    }

    private func deleteReminder(_ reminder: ReminderModel) {
        reminder.isDeleted = true
        NotificationManager.shared.cancelReminder(reminder)
    }
}

#Preview {
    RemindersView(task: TaskModel.sampleTasks.first!)
        .modelContainer(DatabaseConfiguration.makePreviewContainer())
}
