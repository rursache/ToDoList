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
    @State private var currentDetent: PresentationDetent = .medium
    @FocusState private var isContentFocused: Bool

    private var isNewTask: Bool { task == nil }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                TextField(
                    String(localized: "taskContentPlaceholder", defaultValue: "What do you need to do?"),
                    text: $content,
                    axis: .vertical
                )
                .font(.body)
                .lineLimit(1...5)
                .focused($isContentFocused)
                .submitLabel(.done)
                .onSubmit { save() }

                dueDateChips

                if showDatePicker {
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { date ?? Date() },
                            set: { date = $0 }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                }

                Divider()

                bottomActionRow
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .navigationTitle(isNewTask ? "" : String(localized: "editTask", defaultValue: "Edit Task"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel", defaultValue: "Cancel")) {
                        dismiss()
                    }
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
                if isNewTask {
                    isContentFocused = true
                }
            }
            .onChange(of: showDatePicker) { _, showing in
                withAnimation {
                    currentDetent = showing ? .large : .medium
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
        .presentationDetents([.medium, .large], selection: $currentDetent)
        .presentationDragIndicator(.visible)
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
                    date = quickDate(for: Date())
                    showDatePicker = false
                }

                quickDateChip(
                    String(localized: "dateTomorrow", defaultValue: "Tomorrow"),
                    systemImage: "sunrise",
                    isSelected: date?.isTomorrow == true,
                    tintColor: .orange
                ) {
                    date = quickDate(for: .tomorrow)
                    showDatePicker = false
                }

                quickDateChip(
                    String(localized: "dateNextWeek", defaultValue: "Next Week"),
                    systemImage: "calendar.badge.plus",
                    isSelected: isDateNextWeek,
                    tintColor: .purple
                ) {
                    date = quickDate(for: .nextWeek)
                    showDatePicker = false
                }

                quickDateChip(
                    customDateLabel,
                    systemImage: "calendar.badge.clock",
                    isSelected: showDatePicker || isCustomDate,
                    tintColor: .blue
                ) {
                    showDatePicker.toggle()
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

    // MARK: - Bottom Action Row

    private var bottomActionRow: some View {
        HStack(spacing: 8) {
            Button {
                showPriorityPicker = true
            } label: {
                Label(
                    priority == .none
                        ? String(localized: "priority", defaultValue: "Priority")
                        : priority.displayName,
                    systemImage: priority.systemImage
                )
                .font(.subheadline)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .tint(priority == .none ? .secondary : priority.color)

            if let task {
                Button {
                    showComments = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                        let count = task.activeComments.count
                        if count > 0 {
                            Text("\(count)")
                        }
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
                        let count = task.activeReminders.count
                        if count > 0 {
                            Text("\(count)")
                        }
                    }
                    .font(.subheadline)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .tint(.secondary)
            }

            Spacer()

            Button {
                save()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
            }
            .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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

    private func quickDate(for day: Date) -> Date {
        Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: day) ?? day
    }

    private var isDateNextWeek: Bool {
        guard let date else { return false }
        return Calendar.current.isDate(date, inSameDayAs: Date.nextWeek)
    }

    private var isCustomDate: Bool {
        guard let date else { return false }
        return !date.isToday && !date.isTomorrow && !isDateNextWeek
    }

    private var customDateLabel: String {
        if isCustomDate, let date {
            return date.formatted(style: .taskRow)
        }
        return String(localized: "pickDate", defaultValue: "Pick Date")
    }

    // MARK: - Save

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
