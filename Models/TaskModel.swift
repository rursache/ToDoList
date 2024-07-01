//
//  Task.swift
//  ToDoList
//
//  Created by Radu Ursache on 01.07.2024.
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class TaskModel: Identifiable {
    var name: String!
    var detail: String?
    var date: Date?
    var priority = TaskPriority.normal
    var completed: Bool = false
    
    init(name: String, detail: String? = nil, date: Date? = nil, priority: TaskPriority = .normal) {
        self.name = name
        self.detail = detail
        self.date = date
        self.priority = priority
    }
}

extension TaskModel {
    enum TaskPriority: Int, CaseIterable, Codable {
        case low = 0
        case normal = 1
        case high = 2
        case critical = 3
        
        var name: String {
            switch self {
                case .low: "Low"
                case .normal: "Normal"
                case .high: "High"
                case .critical: "Critical"
            }
        }
        
        var color: Color {
            switch self {
                case .low: .secondary
                case .normal: .blue
                case .high: .orange
                case .critical: .red
            }
        }
    }
}

extension TaskModel {
    static var mocks: [TaskModel] {
        let taskTuples: [(name: String, detail: String)] = [
            ("Buy groceries", "Don't forget milk"),
            ("Finish project", "Due next week"),
            ("Call mom", "Her birthday is coming up"),
            ("Exercise", "30 minutes cardio"),
            ("Read book", "Chapter 5-7"),
            ("Pay bills", "Electricity and water"),
            ("Clean house", "Focus on bathroom"),
            ("Write report", "Include graphs"),
            ("Learn Swift", "Study SwiftUI"),
            ("Plan vacation", "Check flight prices")
        ]
        
        return (0..<taskTuples.count).map { index in
            let taskTuple = taskTuples[index]
            let name = taskTuple.name
            let detail = Bool.random() ? taskTuple.detail : nil
            let date = Bool.random() ? Date.now.addingTimeInterval(Double.random(in: 0...7776000)) : nil // 7776000 seconds = 3 months
            let priority = TaskPriority.allCases.randomElement()!
            
            let task = TaskModel(name: name, detail: detail, date: date, priority: priority)
            task.completed = Bool.random()
            return task
        }
    }
}
