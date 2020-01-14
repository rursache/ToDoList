//
//  RowController.swift
//  ToDoList
//
//  Created by Radu Ursache on 14/01/2020.
//  Copyright © 2020 Radu Ursache. All rights reserved.
//

import UIKit
import WatchKit

class RowController: NSObject {
	@IBOutlet weak var taskTitleLabel: WKInterfaceLabel!
	@IBOutlet weak var completeButton: WKInterfaceButton!
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    static var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }
    static var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    }
    static var nextWeek: Date {
        return Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    }
}
