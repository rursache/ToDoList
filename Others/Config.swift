//
//  Config.swift
//  ToDoList
//
//  Created by Radu Ursache on 20/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit

class Config: NSObject {
    class Features: NSObject {
        static let useSmallAddTask = true
        static let enablePriority = true
        static let enableComments = true
    }
    
    class General: NSObject {
        static let addTaskMaxNumberOfLines: Int = 6
        static let dateFormatter = { () -> DateFormatter in
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM, HH:mm"
            return formatter
        }
        static let priorityColors = [Config.Colors.red, Config.Colors.orange, Config.Colors.yellow, Config.Colors.green]
        static let priorityTitles = ["Highest", "High", "Normal", "Low", "None"]
        static let sortTitles = ["Date (Asc)", "Date (Desc)", "Priority (Asc)", "Priority (Desc)"] // also update in TasksViewController
    }
    
    class Colors: NSObject {
        static let red = UIColor(red:0.82, green:0.24, blue:0.11, alpha:1.0)
        static let green = UIColor(red:0.18, green:0.80, blue:0.44, alpha:1.0)
        static let yellow = UIColor(red:0.95, green:0.77, blue:0.06, alpha:1.0)
        static let orange = UIColor(red:0.90, green:0.49, blue:0.13, alpha:1.0)
        static let blue = UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0)
    }
    
    class UserDefaults: NSObject {
        static let neverSyncedBefore = "neverSyncedBefore"
    }
}
