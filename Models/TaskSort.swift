//
//  TaskSort.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import Foundation
import SwiftData

enum TaskSort: Int, CaseIterable, Identifiable {
    case dateAscending = 0
    case dateDescending
    case priorityAscending
    case priorityDescending
    case manual

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .dateAscending: String(localized: "sortDateAsc", defaultValue: "Date (Asc)")
        case .dateDescending: String(localized: "sortDateDesc", defaultValue: "Date (Desc)")
        case .priorityAscending: String(localized: "sortPriorityAsc", defaultValue: "Priority (Asc)")
        case .priorityDescending: String(localized: "sortPriorityDesc", defaultValue: "Priority (Desc)")
        case .manual: String(localized: "sortManual", defaultValue: "Manual")
        }
    }

    var sortDescriptors: [SortDescriptor<TaskModel>] {
        switch self {
        case .dateAscending:
            [SortDescriptor(\.date, order: .forward), SortDescriptor(\.createdDate, order: .forward)]
        case .dateDescending:
            [SortDescriptor(\.date, order: .reverse), SortDescriptor(\.createdDate, order: .reverse)]
        case .priorityAscending:
            [SortDescriptor(\.priority, order: .forward), SortDescriptor(\.createdDate, order: .forward)]
        case .priorityDescending:
            [SortDescriptor(\.priority, order: .reverse), SortDescriptor(\.createdDate, order: .reverse)]
        case .manual:
            [SortDescriptor(\.sortOrder, order: .forward), SortDescriptor(\.createdDate, order: .reverse)]
        }
    }
}

extension Array where Element == TaskModel {
    func sorted(using sort: TaskSort) -> [TaskModel] {
        switch sort {
        case .dateAscending:
            sorted { ($0.date ?? .distantFuture) < ($1.date ?? .distantFuture) }
        case .dateDescending:
            sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
        case .priorityAscending:
            sorted { $0.priority < $1.priority }
        case .priorityDescending:
            sorted { $0.priority > $1.priority }
        case .manual:
            sorted { $0.sortOrder < $1.sortOrder }
        }
    }
}
