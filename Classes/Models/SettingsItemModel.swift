//
//  SettingsItemModel.swift
//  ToDoList
//
//  Created by Radu Ursache on 25/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit

class SettingsItemModel: NSObject {
    var title = ""
    var subtitle: String?
    var icon = UIImage()
    var rightTitle: String?
    
    override init() {
        super.init()
    }
    
    convenience init(title: String, icon: String, subtitle: String?, rightTitle: String?) {
        self.init()
        
        self.title = title
        self.icon = UIImage(named: icon)!
        self.subtitle = subtitle
        self.rightTitle = rightTitle
    }
}

class SettingsItemSection: NSObject {
    var items = [SettingsItemModel]()
    
    override init() {
        super.init()
    }
    
    convenience init(items: [SettingsItemModel]) {
        self.init()
        
        self.items = items
    }
}
