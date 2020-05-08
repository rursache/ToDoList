//
//  ThemeTableViewCell.swift
//  ToDoList
//
//  Created by Radu Ursache on 16/01/2020.
//  Copyright © 2020 Radu Ursache. All rights reserved.
//

import UIKit

class ThemeTableViewCell: UITableViewCell {

	@IBOutlet weak var roundedView: UIView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var checkmarkImageView: UIImageView!
	@IBOutlet weak var checkmarkView: UIView!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        
		if #available(iOS 13.0, *) {
			self.checkmarkImageView.overrideUserInterfaceStyle = .light
		}
		self.checkmarkView.isHidden = !self.isSelected
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.checkmarkView.isHidden = !self.isSelected
    }
}
