//
//  TaskTableViewCell.swift
//  ToDoList
//
//  Created by Radu Ursache on 23/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var taskDateLabel: UILabel!
    @IBOutlet weak var priorityButton: LeftAlignedIconButton!
    @IBOutlet weak var commentsButton: LeftAlignedIconButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        checkBoxButton.imageView?.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    class func getIdentifier() -> String {
        return "taskCell"
    }
}
