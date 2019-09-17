//
//  HomeItemModel.swift
//  ToDoList
//
//  Created by Radu Ursache on 21/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit

class HomeItemModel: NSObject {
    var title = ""
    var icon = ""
    var listType: ListType = .All
    var count = 0
    
    enum ListType: String {
        case All = "all"
        case Today = "today"
        case Tomorrow = "tomorrow"
        case Week = "week"
        case Custom = "custom"
        case Completed = "completed"
    }
    
    override init() {
        super.init()
    }
    
    convenience init(title: String, icon: String, listType: ListType, count: Int) {
        self.init()
        
        self.title = title
        self.icon = icon
        self.listType = listType
        self.count = count
    }
}
