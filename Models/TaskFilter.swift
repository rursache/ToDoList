//
//  TaskFilter.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

enum TaskFilter: Int, CaseIterable, Identifiable {
    case all = 0
    case today
    case tomorrow
    case week
    case custom
    case completed

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .all: String(localized: "filterAll", defaultValue: "All Tasks")
        case .today: String(localized: "filterToday", defaultValue: "Today")
        case .tomorrow: String(localized: "filterTomorrow", defaultValue: "Tomorrow")
        case .week: String(localized: "filterWeek", defaultValue: "Next 7 Days")
        case .custom: String(localized: "filterCustom", defaultValue: "Custom Interval")
        case .completed: String(localized: "filterCompleted", defaultValue: "Completed")
        }
    }

    var systemImage: String {
        switch self {
        case .all: "tray"
        case .today: "sun.max"
        case .tomorrow: "sunrise"
        case .week: "calendar"
        case .custom: "calendar.badge.clock"
        case .completed: "checkmark.circle"
        }
    }
}
