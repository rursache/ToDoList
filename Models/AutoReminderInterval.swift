//
//  AutoReminderInterval.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import Foundation

enum AutoReminderInterval: Int, CaseIterable, Identifiable {
    case none = 0
    case tenMinutes = 10
    case thirtyMinutes = 30
    case oneHour = 60

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .none: String(localized: "reminderNone", defaultValue: "None")
        case .tenMinutes: String(localized: "reminder10min", defaultValue: "10 minutes before")
        case .thirtyMinutes: String(localized: "reminder30min", defaultValue: "30 minutes before")
        case .oneHour: String(localized: "reminder1h", defaultValue: "1 hour before")
        }
    }
}
