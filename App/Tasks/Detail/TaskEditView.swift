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
    @State private var savedTask: TaskModel?
    @State private var detectedDateResult: SmartDateParser.Result?
    @State private var userManuallySetDate: Bool = false
    @FocusState private var isContentFocused: Bool

    private let smartDateParser = SmartDateParser()

    private static let detent: PresentationDetent = .height(295)
    private var isNewTask: Bool { task == nil && savedTask == nil }
    private var currentTask: TaskModel? { task ?? savedTask }

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
                .onChange(of: content) { _, newValue in
                    guard !userManuallySetDate else { return }
                    detectedDateResult = smartDateParser.parse(newValue)
                }

                // Smart date suggestion
                if let result = detectedDateResult {
                    detectedDateChip(result)
                }

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

                // Comments & Reminders
                HStack(spacing: 8) {
                    Spacer()

                    Button {
                        ensureTaskSaved()
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
                        ensureTaskSaved()
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
                    .accessibilityLabel("Priority")
                    .accessibilityValue(priority.displayName)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        save()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                    .accessibilityLabel("Save task")
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
                    if task.date != nil {
                        userManuallySetDate = true
                    }
                } else if let defaultDate {
                    date = defaultDate.startOfDay
                    hasTime = false
                }
            }
            .task {
                if isNewTask {
                    try? await Task.sleep(for: .milliseconds(100))
                    isContentFocused = true
                }
            }
            .sheet(isPresented: $showComments) {
                if let currentTask {
                    CommentsView(task: currentTask)
                }
            }
            .sheet(isPresented: $showReminders) {
                if let currentTask {
                    RemindersView(task: currentTask)
                }
            }
        }
        .presentationDetents([Self.detent])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(date: $date, hasTime: $hasTime)
        }
        .onDisappear {
            guard let task = currentTask else { return }
            task.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
            task.taskDescription = taskDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            task.date = date
            task.hasTime = hasTime
            task.taskPriority = priority
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
                    userManuallySetDate = true
                    detectedDateResult = nil
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
                    userManuallySetDate = true
                    detectedDateResult = nil
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
                    userManuallySetDate = true
                    detectedDateResult = nil
                }

                quickDateChip(
                    customDateLabel,
                    systemImage: "calendar.badge.clock",
                    isSelected: isCustomDate,
                    tintColor: .blue
                ) {
                    isContentFocused = false
                    showDatePicker = true
                    userManuallySetDate = true
                    detectedDateResult = nil
                }

                if date != nil {
                    quickDateChip(
                        String(localized: "clearDate", defaultValue: "Clear"),
                        systemImage: "xmark",
                        isSelected: true,
                        tintColor: .red
                    ) {
                        date = nil
                        hasTime = false
                        showDatePicker = false
                        userManuallySetDate = false
                        detectedDateResult = smartDateParser.parse(content)
                    }
                }
            }
        }
    }

    // MARK: - Smart Date Chip

    private func detectedDateChip(_ result: SmartDateParser.Result) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .foregroundStyle(.purple)
                .font(.subheadline)

            Text(result.date.formatted(style: .taskRow, hasTime: result.hasTime))
                .font(.subheadline)
                .foregroundStyle(.primary)

            Spacer()

            Button {
                content = result.cleanedContent
                date = result.date
                hasTime = result.hasTime
                detectedDateResult = nil
                userManuallySetDate = true
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Accept detected date")

            Button {
                detectedDateResult = nil
                userManuallySetDate = true
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss detected date")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.purple.opacity(0.1), in: Capsule())

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
        .accessibilityValue(isSelected ? "Selected" : String(""))
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
        let count = currentTask?.activeComments.count ?? 0
        let base = String(localized: "comments", defaultValue: "Comments")
        return count > 0 ? "\(base) (\(count))" : base
    }

    private var remindersLabel: String {
        let count = currentTask?.activeReminders.count ?? 0
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

    private var minSortOrder: Int {
        let descriptor = FetchDescriptor<TaskModel>(
            predicate: #Predicate { !$0.isDeleted },
            sortBy: [SortDescriptor(\.sortOrder, order: .forward)]
        )
        let tasks = try? modelContext.fetch(descriptor)
        return tasks?.first?.sortOrder ?? 0
    }

    private func applyDetectedDateIfNeeded() {
        guard !userManuallySetDate, let result = detectedDateResult else { return }
        content = result.cleanedContent
        date = result.date
        hasTime = result.hasTime
        detectedDateResult = nil
        userManuallySetDate = true
    }

    private func ensureTaskSaved() {
        guard currentTask == nil else { return }
        applyDetectedDateIfNeeded()
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = trimmed.isEmpty ? String(localized: "untitledTask", defaultValue: "Untitled") : trimmed
        let newTask = TaskModel(content: name, taskDescription: taskDescription.trimmingCharacters(in: .whitespacesAndNewlines), date: date, priority: priority.rawValue)
        newTask.hasTime = hasTime
        newTask.sortOrder = minSortOrder - 1
        modelContext.insert(newTask)
        savedTask = newTask
    }

    private func save() {
        applyDetectedDateIfNeeded()
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let trimmedDescription = taskDescription.trimmingCharacters(in: .whitespacesAndNewlines)

        if let existingTask = currentTask {
            existingTask.content = trimmed
            existingTask.taskDescription = trimmedDescription
            existingTask.date = date
            existingTask.hasTime = hasTime
            existingTask.taskPriority = priority
        } else {
            let newTask = TaskModel(content: trimmed, taskDescription: trimmedDescription, date: date, priority: priority.rawValue)
            newTask.hasTime = hasTime
            newTask.sortOrder = minSortOrder - 1
            modelContext.insert(newTask)
            scheduleAutoReminder(for: newTask)
        }

        dismiss()
    }

    private func scheduleAutoReminder(for task: TaskModel) {
        let reminderMinutes = appSettings.autoReminderMinutes
        guard reminderMinutes > 0, hasTime, let taskDate = date, taskDate > Date() else { return }

        let reminder = ReminderModel()
        reminder.text = String(localized: "autoReminder", defaultValue: "Task reminder")
        reminder.date = taskDate.addingTimeInterval(-Double(reminderMinutes) * 60)
        reminder.task = task
        modelContext.insert(reminder)

        let capturedTask = task
        let capturedReminder = reminder
        Task {
            try? await NotificationManager.shared.scheduleReminder(for: capturedTask, reminder: capturedReminder)
        }
    }
}

#Preview("New Task") {
    TaskEditView()
        .modelContainer(DatabaseConfiguration.makePreviewContainer())
        .environment(AppSettings.shared)
}

#Preview("Edit Task") {
    TaskEditView(task: TaskModel.sampleTasks.first!)
        .modelContainer(DatabaseConfiguration.makePreviewContainer())
        .environment(AppSettings.shared)
}
