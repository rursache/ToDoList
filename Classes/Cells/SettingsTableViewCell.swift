//
//  SettingsTableViewCell.swift
//  ToDoList
//
//  Created by Radu Ursache on 25/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var rightSwitch: UISwitch!
    
    func updateUI() {
        self.rightSwitch.onTintColor = Utils().getCurrentThemeColor()
    }
    
    class func getIdentifier() -> String {
        return "settingsCell"
    }
}
