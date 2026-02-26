//
//  CommentModel.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class CommentModel {
    var id: UUID = UUID()
    var content: String = ""
    var imageData: Data?
    var date: Date = Date()
    var isDeleted: Bool = false

    var task: TaskModel?

    init() {}

    init(content: String, date: Date = Date()) {
        self.content = content
        self.date = date
    }

    init(imageData: Data, date: Date = Date()) {
        self.imageData = imageData
        self.date = date
    }

    var isImageComment: Bool {
        imageData != nil && !content.isEmpty == false
    }
}
