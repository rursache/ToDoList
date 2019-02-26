//
//  ThemeModel.swift
//  ToDoList
//
//  Created by Radu Ursache on 25/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit

class ThemeModel: NSObject {
    var name = String()
    var color = UIColor()
    var appIcon: String?
    
    override init() {
        super.init()
    }
    
    convenience init(name: String, color: UIColor, appIcon: String?) {
        self.init()
        
        self.name = name
        self.color = color
        self.appIcon = appIcon
    }
}
