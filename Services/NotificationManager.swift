//
//  NotificationManager.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import Foundation
import UserNotifications
import SwiftData

@Observable
final class NotificationManager: @unchecked Sendable {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()

    private init() {}

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .badge, .sound])
    }

    func scheduleReminder(for task: TaskModel, reminder: ReminderModel) async throws {
        guard reminder.date > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification", defaultValue: "Reminder")
        content.body = reminder.text.isEmpty ? task.content : reminder.text
        content.sound = .default
        content.badge = 1
        content.userInfo = [
            "taskId": task.id.uuidString,
            "taskName": task.content,
            "reminderId": reminder.id.uuidString
        ]

        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminder.date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(
            identifier: reminder.id.uuidString,
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    func cancelReminder(_ reminder: ReminderModel) {
        center.removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
    }

    func cancelAllReminders(for task: TaskModel) {
        let ids = (task.reminders ?? []).map { $0.id.uuidString }
        guard !ids.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    func rescheduleAllReminders(using modelContext: ModelContext) async {
        center.removeAllPendingNotificationRequests()

        let descriptor = FetchDescriptor<TaskModel>(
            predicate: #Predicate { !$0.isDeleted && !$0.isCompleted }
        )

        guard let tasks = try? modelContext.fetch(descriptor) else { return }

        for task in tasks {
            for reminder in (task.reminders ?? []) where !reminder.isDeleted && reminder.date > Date() {
                try? await scheduleReminder(for: task, reminder: reminder)
            }
        }
    }

    func updateBadgeCount(using modelContext: ModelContext) {
        let today = Date().startOfDay
        let tomorrow = Date.tomorrow.startOfDay

        let descriptor = FetchDescriptor<TaskModel>(
            predicate: #Predicate {
                !$0.isDeleted && !$0.isCompleted
            }
        )

        guard let tasks = try? modelContext.fetch(descriptor) else { return }
        let todayCount = tasks.filter { task in
            guard let date = task.date else { return false }
            return date >= today && date < tomorrow
        }.count

        UNUserNotificationCenter.current().setBadgeCount(todayCount)
    }
}
