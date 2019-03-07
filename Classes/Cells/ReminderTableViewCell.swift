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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    class func getIdentifier() -> String {
        return "reminderCell"
    }
}
