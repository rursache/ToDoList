//
//  CommentTableViewCell.swift
//  ToDoList
//
//  Created by Radu Ursache on 05/03/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!

    class func getIdentifier() -> String {
        return "reminderCell"
    }
}
