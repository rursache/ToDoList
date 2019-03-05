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
    var showSwitch = false
    var switchIsOn = false
    
    override init() {
        super.init()
    }
    
    convenience init(title: String, icon: String, subtitle: String?, rightTitle: String?, showSwitch: Bool = false, switchIsOn: Bool = false) {
        self.init()
        
        self.title = title
        self.icon = UIImage(named: icon)!
        self.subtitle = subtitle
        self.rightTitle = rightTitle
        self.showSwitch = showSwitch
        self.switchIsOn = switchIsOn
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
