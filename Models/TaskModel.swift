//
//  TaskModel.swift
//  ToDoList
//
//  Created by Radu Ursache on 01.07.2024.
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class TaskModel {
    var id: UUID = UUID()
    var content: String = ""
    var taskDescription: String = ""
    var date: Date?
    var hasTime: Bool = false
    var completedDate: Date?
    var priority: Int = 0
    var isCompleted: Bool = false
    var isDeleted: Bool = false
    var createdDate: Date = Date()
    var sortOrder: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \CommentModel.task)
    var comments: [CommentModel]? = []

    @Relationship(deleteRule: .cascade, inverse: \ReminderModel.task)
    var reminders: [ReminderModel]? = []

    init() {}

    init(content: String, taskDescription: String = "", date: Date? = nil, priority: Int = 0) {
        self.content = content
        self.taskDescription = taskDescription
        self.date = date
        self.priority = priority
    }

    var taskPriority: TaskPriority {
        get { TaskPriority(rawValue: priority) ?? .none }
        set { priority = newValue.rawValue }
    }

    var activeComments: [CommentModel] {
        (comments ?? []).filter { !$0.isDeleted }
    }

    var activeReminders: [ReminderModel] {
        (reminders ?? []).filter { !$0.isDeleted }
    }
}
