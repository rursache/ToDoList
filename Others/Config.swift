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
        static let showTodayTasksAsBadgeNumber = true
        static let showCompleteButtonInTaskOptions = false
    }
    
    class General: NSObject {
        static let appName = "ToDoList"
        
        static let addTaskMaxNumberOfLines: Int = 6
        static let dateFormatter = { () -> DateFormatter in
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM, HH:mm"
            return formatter
        }
        
        static let timeFormatter = { () -> DateFormatter in
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
        }
        
        static let notificationDefaultDelayForNotifications = -30 // minutes
        
        static let themes = [ThemeModel(name: "Alizarin Red", color: Colors.red, appIcon: nil),
                             ThemeModel(name: "Vanadyl Blue", color: Colors.blue, appIcon: "IconBlue"),
                             ThemeModel(name: "Skirret Green", color: Colors.green, appIcon: "IconGreen"),
                             ThemeModel(name: "Sunflower Yellow", color: Colors.yellow, appIcon: "IconYellow"),
                             ThemeModel(name: "Radiant Orange", color: Colors.orange, appIcon: "IconOrange"),
                             ThemeModel(name: "Salmon Pink", color: Colors.pink, appIcon: "IconPink"),
                             ThemeModel(name: "Midnight Black", color: Colors.black, appIcon: "IconBlack"),
                             ThemeModel(name: "True Black", color: Colors.night, appIcon: "IconNight")
                            ]
        
        static let languages = [LanguageModel(name: "English", code: "en_US"), LanguageModel(name: "Romanian", code: "ro_RO")]
        
        static let linksOptions = ["In App", "Safari"]
        static let startPageTitles = ["Overview", "All Tasks", "Today", "Tomorrow", "Next 7 Days", "Custom Interval"]
        static let priorityColors = [Config.Colors.red, Config.Colors.orange, Config.Colors.yellow, Config.Colors.green]
        static let priorityTitles = ["Highest", "High", "Normal", "Low", "None"]
        static let sortTitles = ["Date (Asc)", "Date (Desc)", "Priority (Asc)", "Priority (Desc)"] // also update in TasksViewController
    }
    
    class Colors: NSObject {
        static let red = UIColor(hexString: "#d63031") // UIColor(red:0.82, green:0.24, blue:0.11, alpha:1.0)
        static let green = UIColor(hexString: "#20bf6b") // UIColor(red:0.18, green:0.80, blue:0.44, alpha:1.0)
        static let yellow = UIColor(hexString: "#f1c40f") // UIColor(red:0.95, green:0.77, blue:0.06, alpha:1.0)
        static let orange = UIColor(hexString: "#f39c12") // UIColor(red:0.90, green:0.49, blue:0.13, alpha:1.0)
        static let blue = UIColor(hexString: "#0984e3")
        static let black = UIColor(hexString: "#2d3436")
        static let pink = UIColor(hexString: "#e3acac")
        static let night = UIColor.black
    }
    
    class UserDefaults: NSObject {
        static let neverSyncedBefore = "neverSyncedBefore"
        static let userFullName = "userFullName"
        static let startPage = "startPage"
        static let theme = "theme"
        static let language = "language"
        static let openLinks = "openLinksOption"
        static let disableAutoReminders = "disableAutoReminders"
    }
    
    class Notifications: NSObject {
        static let themeUpdated = NSNotification.Name("themeUpdated")
        static let shouldReloadData = NSNotification.Name("shouldReloadData")
        static let threeDTouchShortcut = NSNotification.Name("3DTouchShortcut")
    }
}
