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

    var isPastDay: Bool {
        endOfDay < Date()
    }

    func formatted(style: DateFormattingStyle, hasTime: Bool = true) -> String {
        switch style {
        case .taskRow:
            return taskRowFormatted(hasTime: hasTime)
        case .sectionHeader:
            return sectionHeaderFormatted
        case .reminder:
            return reminderFormatted
        case .comment:
            return commentFormatted
        }
    }

    private func taskRowFormatted(hasTime: Bool) -> String {
        let timeSuffix: String
        if hasTime {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            timeSuffix = ", \(timeFormatter.string(from: self))"
        } else {
            timeSuffix = ""
        }

        if isToday {
            return String(localized: "dateToday", defaultValue: "Today") + timeSuffix
        } else if isTomorrow {
            return String(localized: "dateTomorrow", defaultValue: "Tomorrow") + timeSuffix
        } else if isYesterday {
            return String(localized: "dateYesterday", defaultValue: "Yesterday") + timeSuffix
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM"
            return dateFormatter.string(from: self) + timeSuffix
        }
    }

    private var sectionHeaderFormatted: String {
        if isToday {
            return String(localized: "dateToday", defaultValue: "Today")
        } else if isTomorrow {
            return String(localized: "dateTomorrow", defaultValue: "Tomorrow")
        } else if isYesterday {
            return String(localized: "dateYesterday", defaultValue: "Yesterday")
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
                ? "EEEE, d MMM"
                : "EEEE, d MMM yyyy"
            return formatter.string(from: self)
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
    case sectionHeader
    case reminder
    case comment
}
