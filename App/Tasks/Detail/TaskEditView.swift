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
    var defaultDate: Date?

    @State private var content: String = ""
    @State private var taskDescription: String = ""
    @State private var date: Date?
    @State private var hasTime: Bool = false
    @State private var showDatePicker = false
    @State private var priority: TaskPriority = .none
    @State private var showPriorityPicker = false
    @State private var showComments = false
    @State private var showReminders = false
    @FocusState private var isContentFocused: Bool

    private static let newTaskDetent: PresentationDetent = .height(210)
    private static let editTaskDetent: PresentationDetent = .height(260)
    private var isNewTask: Bool { task == nil }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                // Title
                TextField(
                    String(localized: "taskContentPlaceholder", defaultValue: "Task name"),
                    text: $content,
                    axis: .vertical
                )
                .font(.title3)
                .lineLimit(1...5)
                .focused($isContentFocused)
                .submitLabel(.next)
                .padding(.bottom, 2)

                // Description
                TextField(
                    String(localized: "taskDescriptionPlaceholder", defaultValue: "Description"),
                    text: $taskDescription,
                    axis: .vertical
                )
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(1...3)
                .contentShape(.rect)
                .padding(.bottom, 8)

                Spacer().frame(height: 4)

                // Due date chips
                dueDateChips

                // Comments & Reminders (edit mode only)
                if let task {
                    HStack(spacing: 8) {
                        Spacer()

                        Button {
                            showComments = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "bubble.left")
                                Text(commentsLabel)
                            }
                            .font(.subheadline)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .tint(.secondary)

                        Button {
                            showReminders = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "bell")
                                Text(remindersLabel)
                            }
                            .font(.subheadline)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .tint(.secondary)

                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 0)
            .navigationTitle(isNewTask ? String(localized: "newTask", defaultValue: "New Task") : String(localized: "editTask", defaultValue: "Edit Task"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        showPriorityPicker = true
                    } label: {
                        Image(systemName: priority.systemImage)
                            .foregroundStyle(priority == .none ? .secondary : priority.color)
                            .font(.subheadline)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        save()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
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
                    taskDescription = task.taskDescription
                    date = task.date
                    hasTime = task.hasTime
                    priority = task.taskPriority
                } else if let defaultDate {
                    date = defaultDate.startOfDay
                    hasTime = false
                }
            }
            .task {
                try? await Task.sleep(for: .milliseconds(100))
                isContentFocused = true
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
        .presentationDetents([isNewTask ? Self.newTaskDetent : Self.editTaskDetent])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(date: $date, hasTime: $hasTime)
        }
    }

    // MARK: - Due Date Chips

    private var dueDateChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                quickDateChip(
                    String(localized: "dateToday", defaultValue: "Today"),
                    systemImage: "calendar",
                    isSelected: date?.isToday == true,
                    tintColor: .green
                ) {
                    date = Date().startOfDay
                    hasTime = false
                    showDatePicker = false
                }

                quickDateChip(
                    String(localized: "dateTomorrow", defaultValue: "Tomorrow"),
                    systemImage: "sunrise",
                    isSelected: date?.isTomorrow == true,
                    tintColor: .orange
                ) {
                    date = Date.tomorrow.startOfDay
                    hasTime = false
                    showDatePicker = false
                }

                quickDateChip(
                    String(localized: "dateNextWeek", defaultValue: "Next Week"),
                    systemImage: "calendar.badge.plus",
                    isSelected: isDateNextWeek,
                    tintColor: .purple
                ) {
                    date = Date.nextWeek.startOfDay
                    hasTime = false
                    showDatePicker = false
                }

                quickDateChip(
                    customDateLabel,
                    systemImage: "calendar.badge.clock",
                    isSelected: isCustomDate,
                    tintColor: .blue
                ) {
                    isContentFocused = false
                    showDatePicker = true
                }

                if date != nil {
                    Button {
                        date = nil
                        showDatePicker = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func quickDateChip(
        _ title: String,
        systemImage: String,
        isSelected: Bool,
        tintColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.capsule)
        .tint(isSelected ? tintColor : .secondary)
    }

    private var isDateNextWeek: Bool {
        guard let date else { return false }
        return Calendar.current.isDate(date, inSameDayAs: Date.nextWeek)
    }

    private var isCustomDate: Bool {
        guard let date else { return false }
        return !date.isToday && !date.isTomorrow && !isDateNextWeek
    }

    private var commentsLabel: String {
        let count = task?.activeComments.count ?? 0
        let base = String(localized: "comments", defaultValue: "Comments")
        return count > 0 ? "\(base) (\(count))" : base
    }

    private var remindersLabel: String {
        let count = task?.activeReminders.count ?? 0
        let base = String(localized: "reminders", defaultValue: "Reminders")
        return count > 0 ? "\(base) (\(count))" : base
    }

    private var customDateLabel: String {
        if isCustomDate, let date {
            return date.formatted(style: .taskRow, hasTime: hasTime)
        }
        return String(localized: "pickDate", defaultValue: "Pick Date")
    }

    // MARK: - Save

    private func save() {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let trimmedDescription = taskDescription.trimmingCharacters(in: .whitespacesAndNewlines)

        if let task {
            task.content = trimmed
            task.taskDescription = trimmedDescription
            task.date = date
            task.hasTime = hasTime
            task.taskPriority = priority
        } else {
            let newTask = TaskModel(content: trimmed, taskDescription: trimmedDescription, date: date, priority: priority.rawValue)
            newTask.hasTime = hasTime
            modelContext.insert(newTask)

            if !appSettings.disableAutoReminders, let taskDate = date, taskDate > Date() {
                let reminder = ReminderModel()
                reminder.text = String(localized: "autoReminder", defaultValue: "Task reminder")
                reminder.date = taskDate.addingTimeInterval(-30 * 60)
                reminder.task = newTask
                modelContext.insert(reminder)

                let capturedTask = newTask
                let capturedReminder = reminder
                Task {
                    try? await NotificationManager.shared.scheduleReminder(for: capturedTask, reminder: capturedReminder)
                }
            }
        }

        dismiss()
    }
}

// MARK: - Date Picker Sheet

private struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var date: Date?
    @Binding var hasTime: Bool

    @State private var selectedDate: Date = Date()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: hasTime ? [.date, .hourAndMinute] : [.date]
                )
                .datePickerStyle(.graphical)

                Toggle(isOn: $hasTime) {
                    Label(
                        String(localized: "addTime", defaultValue: "Time"),
                        systemImage: "clock"
                    )
                    .font(.subheadline)
                }
                .tint(.blue)
                .padding(.horizontal)
                .onChange(of: hasTime) { _, newValue in
                    if !newValue {
                        selectedDate = selectedDate.startOfDay
                    }
                }

                Spacer()
            }
            .navigationTitle(String(localized: "pickDate", defaultValue: "Pick Date"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel", defaultValue: "Cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "done", defaultValue: "Done")) {
                        date = selectedDate
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            selectedDate = date ?? Date()
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
