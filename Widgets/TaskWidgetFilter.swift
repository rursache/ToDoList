//
//  TaskWidgetFilter.swift
//  Widgets
//
//  Copyright © 2026 RanduSoft. All rights reserved.
//

import AppIntents
import WidgetKit

enum TaskWidgetFilter: String, CaseIterable, AppEnum {
    case today
    case upcoming

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Filter"
    }

    static var caseDisplayRepresentations: [TaskWidgetFilter: DisplayRepresentation] {
        [
            .today: "Today",
            .upcoming: "Upcoming"
        ]
    }

    var displayName: String {
        switch self {
        case .today: "Today"
        case .upcoming: "Upcoming"
        }
    }

    var systemImage: String {
        switch self {
        case .today: "calendar.circle"
        case .upcoming: "calendar.badge.clock"
        }
    }
}

struct TaskWidgetIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Task Filter"
    static let description: IntentDescription = "Choose which tasks to display"

    @Parameter(title: "Filter", default: .today)
    var filter: TaskWidgetFilter
}
