//
//  WidgetCell.swift
//  ToDoListWidget
//
//  Created by Radu Ursache on 13/01/2020.
//  Copyright © 2020 Radu Ursache. All rights reserved.
//

import UIKit

class WidgetCell: UITableViewCell {

	@IBOutlet weak var taskButton: UIButton!
	@IBOutlet weak var taskLabel: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
