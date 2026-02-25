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
}
