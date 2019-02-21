//
//  Utils.swift
//  ToDoList
//
//  Created by Radu Ursache on 20/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit
import LKAlertController

class Utils: NSObject {
    
}

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

extension LKAlertController {
    public func showOK() {
        self.addAction("OK".localized(), style: .cancel, handler: nil)
        self.show()
    }
}

extension UIViewController {
    func showOK(title: String, message: String?) {
        Alert(title: title, message: message).showOK()
    }
}

extension UIBarButtonItem {
    class func itemWith(colorfulImage: UIImage, target: AnyObject, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setImage(colorfulImage.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: button)
        barButtonItem.tintColor = UIColor.white
        
        return barButtonItem
    }
}
