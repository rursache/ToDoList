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
        
        static let contactEmail = "contact[email]randusoft.ro"
		static let toastOnScreenTime = 2.0 // seconds
        static let notificationDefaultDelayForNotifications = -30 // minutes
        
        static let themes = [ThemeModel(name: "Alizarin Red", color: Colors.red, appIcon: nil),
                             ThemeModel(name: "Vanadyl Blue", color: Colors.blue, appIcon: "IconBlue"),
                             ThemeModel(name: "Skirret Green", color: Colors.green, appIcon: "IconGreen"),
                             ThemeModel(name: "Sunflower Yellow", color: Colors.yellow, appIcon: "IconYellow"),
                             ThemeModel(name: "Radiant Orange", color: Colors.orange, appIcon: "IconOrange"),
                             ThemeModel(name: "Rose Pink", color: Colors.pink, appIcon: "IconPinkAlt"),
                             ThemeModel(name: "Midnight Black", color: Colors.black, appIcon: "IconBlack")]//,
//                             ThemeModel(name: "True Black", color: Colors.night, appIcon: "IconNight")]
        
        static let languages = [LanguageModel(name: "LANGUAGE_OPTION_1".localized(), code: "en_US"), LanguageModel(name: "LANGUAGE_OPTION_2".localized(), code: "ro_RO"), LanguageModel(name: "LANGUAGE_OPTION_3".localized(), code: "zh_TW")]
        
        static let linksOptions = ["CONFIG_LINK_PREF1".localized(), "CONFIG_LINK_PREF2".localized()]
        static let startPageTitles = ["CONFIG_OPTIONS_PREF1".localized(), "CONFIG_OPTIONS_PREF2".localized(), "CONFIG_OPTIONS_PREF3".localized(), "CONFIG_OPTIONS_PREF4".localized(), "CONFIG_OPTIONS_PREF5".localized(), "CONFIG_OPTIONS_PREF6".localized(), "CONFIG_OPTIONS_PREF7".localized()]
        static let priorityColors = [Config.Colors.red, Config.Colors.orange, Config.Colors.yellow, Config.Colors.green]
        static let priorityTitles = ["CONFIG_PRIORITY_PREF1".localized(), "CONFIG_PRIORITY_PREF2".localized(), "CONFIG_PRIORITY_PREF3".localized(), "CONFIG_PRIORITY_PREF4".localized(), "CONFIG_PRIORITY_PREF5".localized()]
        static let sortTitles = ["CONFIG_SORT_PREF1".localized(), "CONFIG_SORT_PREF2".localized(), "CONFIG_SORT_PREF3".localized(), "CONFIG_SORT_PREF4".localized()] // also update in TasksViewController
    }
    
    class Colors: NSObject {
        static let red = UIColor(hexString: "#d63031")
        static let green = UIColor(hexString: "#20bf6b")
        static let yellow = UIColor(hexString: "#f1c40f")
        static let orange = UIColor(hexString: "#f39c12")
        static let blue = UIColor(hexString: "#0984e3")
        static let black = UIColor(hexString: "#2d3436")
        static let pink = UIColor(hexString: "#e05384")
        static let night = UIColor.black
    }
    
    class UserDefaults: NSObject {
        static let launchedBefore = "launchedBefore"
        static let neverSyncedBefore = "neverSyncedBefore"
        static let userFullName = "userFullName"
        static let startPage = "startPage"
        static let theme = "theme"
        static let language = "language"
        static let openLinks = "openLinksOption"
        static let disableAutoReminders = "disableAutoReminders"
        static let helpPrompts = "helpPrompts"
    }
    
    class Notifications: NSObject {
        static let themeUpdated = NSNotification.Name("themeUpdated")
        static let shouldReloadData = NSNotification.Name("shouldReloadData")
        static let threeDTouchShortcut = NSNotification.Name("3DTouchShortcut")
		static let completeTask = NSNotification.Name("completeTask")
    }
}
