//
//  ReminderModel.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class ReminderModel {
    var id: UUID = UUID()
    var text: String = ""
    var date: Date = Date()
    var isDeleted: Bool = false

    var task: TaskModel?

    init() {}

    init(text: String, date: Date) {
        self.text = text
        self.date = date
    }
}
