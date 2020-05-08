//
//  CommentTableViewCell.swift
//  ToDoList
//
//  Created by Radu Ursache on 22/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit
import ActiveLabel

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: ActiveLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentLabel.enabledTypes = [.hashtag, .url]
        self.contentLabel.hashtagColor = Config.Colors.green
        self.contentLabel.URLColor = Config.Colors.blue
        self.contentLabel.urlMaximumLength = 25
    }

    class func getIdentifier() -> String {
        return "commentCell"
    }
}
