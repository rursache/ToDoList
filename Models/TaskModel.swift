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
    var name: String = ""
    var detail: String?
    var date: Date?
    var time: Date?
    var priority = TaskPriority.normal
    var completed: Bool = false
    var createdDate: Date = Date()
    
    init(name: String, detail: String? = nil, date: Date? = nil, time: Date? = nil, priority: TaskPriority = .normal) {
        self.name = name
        self.detail = detail
        self.date = date
        self.time = time
        self.priority = priority
        self.createdDate = Date()
    }
}

extension TaskModel {
    enum TaskPriority: Int, CaseIterable, Codable, Identifiable {
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
        
        var id: Int { self.hashValue }
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
            ("Plan vacation", "Check flight prices"),
            ("Attend meeting", "Prepare presentation"),
            ("Update resume", "Add recent projects"),
            ("Fix leaky faucet", "Buy new washer"),
            ("Organize photos", "Create album for last trip"),
            ("Schedule dentist appointment", "Ask about whitening"),
            ("Plant garden", "Buy seeds and soil"),
            ("Practice guitar", "Learn new chord progression"),
            ("Meal prep", "Plan for the week ahead"),
            ("Backup computer files", "Use external hard drive"),
            ("Research new phone", "Compare features and prices"),
            ("Start a blog", "Brainstorm topic ideas"),
            ("Volunteer at shelter", "Sign up for weekend shift"),
            ("Learn a new language", "Download language app"),
            ("Declutter closet", "Donate unused items"),
            ("Network", "Attend industry meetup")
        ]
        
        return (0..<taskTuples.count).map { index in
            let taskTuple = taskTuples[index]
            let name = taskTuple.name
            let detail = Bool.random() ? taskTuple.detail : nil
            let date = Bool.random() ? Date.now.addingTimeInterval(Double.random(in: 0...7776000)) : nil // 7776000 seconds = 3 months
            var time: Date?
            if let _ = date, Bool.random() {
                time = Calendar.current.startOfDay(for: Date()).addingTimeInterval(TimeInterval(Int.random(in: 0..<86400))) // 86400 seconds in a day
            }
            let priority = TaskPriority.allCases.randomElement()!
            
            let task = TaskModel(name: name, detail: detail, date: date, time: time, priority: priority)
            task.completed = Bool.random()
            return task
        }
    }
}

extension Array where Element == TaskModel {
    func sorted() -> [TaskModel] {
        self.sorted { (task1, task2) in
            if let date1 = task1.date, let date2 = task2.date {
                return date1 < date2
            } else if task1.date != nil {
                return true
            } else if task2.date != nil {
                return false
            } else {
                return task1.createdDate < task2.createdDate
            }
        }
    }
}
