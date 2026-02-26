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
        TypeDisplayRepresentation(name: LocalizedStringResource("widgetFilter", defaultValue: "Filter"))
    }

    static var caseDisplayRepresentations: [TaskWidgetFilter: DisplayRepresentation] {
        [
            .today: DisplayRepresentation(title: LocalizedStringResource("filterToday", defaultValue: "Today")),
            .upcoming: DisplayRepresentation(title: LocalizedStringResource("filterUpcoming", defaultValue: "Upcoming"))
        ]
    }

    var displayName: String {
        switch self {
        case .today: String(localized: "filterToday", defaultValue: "Today")
        case .upcoming: String(localized: "filterUpcoming", defaultValue: "Upcoming")
        }
    }

    var emptyText: String {
        switch self {
        case .today: String(localized: "widgetNoTodayTasks", defaultValue: "No today tasks")
        case .upcoming: String(localized: "widgetNoUpcomingTasks", defaultValue: "No upcoming tasks")
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
    static let title: LocalizedStringResource = LocalizedStringResource("widgetTaskFilter", defaultValue: "Task Filter")
    static let description: IntentDescription = IntentDescription(LocalizedStringResource("widgetTaskFilterDescription", defaultValue: "Choose which tasks to display"))

    @Parameter(title: LocalizedStringResource("widgetFilter", defaultValue: "Filter"), default: .today)
    var filter: TaskWidgetFilter
}
