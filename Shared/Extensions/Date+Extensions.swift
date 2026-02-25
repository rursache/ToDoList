//
//  Date+Extensions.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    static var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }

    static var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    }

    static var nextWeek: Date {
        Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    var isPast: Bool {
        self < Date()
    }

    func formatted(style: DateFormattingStyle) -> String {
        switch style {
        case .taskRow:
            return taskRowFormatted
        case .reminder:
            return reminderFormatted
        case .comment:
            return commentFormatted
        }
    }

    private var taskRowFormatted: String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = timeFormatter.string(from: self)

        if isToday {
            return String(localized: "dateToday", defaultValue: "Today") + ", \(timeString)"
        } else if isTomorrow {
            return String(localized: "dateTomorrow", defaultValue: "Tomorrow") + ", \(timeString)"
        } else if isYesterday {
            return String(localized: "dateYesterday", defaultValue: "Yesterday") + ", \(timeString)"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM"
            return dateFormatter.string(from: self) + ", \(timeString)"
        }
    }

    private var reminderFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, HH:mm"
        return formatter.string(from: self)
    }

    private var commentFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, HH:mm"
        return formatter.string(from: self)
    }
}

enum DateFormattingStyle {
    case taskRow
    case reminder
    case comment
}
