//
//  TaskPriority.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

enum TaskPriority: Int, CaseIterable, Codable, Identifiable {
    case none = 0
    case highest = 1
    case high = 2
    case normal = 3
    case low = 4

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .none: String(localized: "priorityNone", defaultValue: "None")
        case .highest: String(localized: "priorityHighest", defaultValue: "Highest")
        case .high: String(localized: "priorityHigh", defaultValue: "High")
        case .normal: String(localized: "priorityNormal", defaultValue: "Normal")
        case .low: String(localized: "priorityLow", defaultValue: "Low")
        }
    }

    var color: Color {
        switch self {
        case .none: .secondary
        case .highest: .red
        case .high: .orange
        case .normal: .yellow
        case .low: .green
        }
    }

    var systemImage: String {
        switch self {
        case .none: "flag"
        case .highest, .high, .normal, .low: "flag.fill"
        }
    }
}
