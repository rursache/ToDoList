//
//  TaskFilter.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

enum TaskFilter: Int, CaseIterable, Identifiable {
    case inbox = 0
    case today
    case upcoming
    case completed

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .inbox: String(localized: "filterInbox", defaultValue: "Inbox")
        case .today: String(localized: "filterToday", defaultValue: "Today")
        case .upcoming: String(localized: "filterUpcoming", defaultValue: "Upcoming")
        case .completed: String(localized: "filterCompleted", defaultValue: "Completed")
        }
    }

    var systemImage: String {
        switch self {
        case .inbox: "tray"
        case .today: "sun.max"
        case .upcoming: "calendar"
        case .completed: "checkmark.circle"
        }
    }

    var emptyTitle: String {
        switch self {
        case .inbox: String(localized: "emptyInboxTitle", defaultValue: "Inbox is empty")
        case .today: String(localized: "emptyTodayTitle", defaultValue: "Nothing due today")
        case .upcoming: String(localized: "emptyUpcomingTitle", defaultValue: "All clear ahead")
        case .completed: String(localized: "emptyCompletedTitle", defaultValue: "No completed tasks")
        }
    }

    var emptyDescription: String {
        switch self {
        case .inbox: String(localized: "emptyInboxDescription", defaultValue: "Tasks you add will appear here.")
        case .today: String(localized: "emptyTodayDescription", defaultValue: "Enjoy your free day or plan something new.")
        case .upcoming: String(localized: "emptyUpcomingDescription", defaultValue: "No upcoming tasks scheduled yet.")
        case .completed: String(localized: "emptyCompletedDescription", defaultValue: "Completed tasks will show up here.")
        }
    }

    var emptySystemImage: String {
        switch self {
        case .inbox: "tray"
        case .today: "sun.max.fill"
        case .upcoming: "calendar.badge.checkmark"
        case .completed: "party.popper"
        }
    }
}
