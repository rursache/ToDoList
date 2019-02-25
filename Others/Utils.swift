//
//  Utils.swift
//  ToDoList
//
//  Created by Radu Ursache on 20/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit
import LKAlertController
import CFNotify
import IceCream

class Utils: NSObject {
    func themeView(view: UIView, setBackgroundColor: Bool = true) {
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        if setBackgroundColor {
            view.backgroundColor = Config.Colors.red
        }
        
        if view is UIButton {
            (view as! UIButton).setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    func startEndDateArray(forDate: Date) -> [Date] {
        return [forDate.startOfDay, forDate.endOfDay]
    }
    
    func userIsLoggedIniCloud() -> Bool {
        return FileManager.default.ubiquityIdentityToken != nil
    }
    
    private func showToast(error: Bool, title: String, message: String) {
        let classicView = CFNotifyView.classicWith(title: title, body: message, theme: error ? .fail(.light) : .success(.light))
        var classicViewConfig = CFNotify.Config()
        classicViewConfig.initPosition = .bottom(.random) //the view is born at the top randomly out of the boundary of screen
        classicViewConfig.appearPosition = .bottom //the view will appear at the top of screen
        classicViewConfig.hideTime = .custom(seconds: 3)
        CFNotify.present(config: classicViewConfig, view: classicView)
    }
    
    func showErrorToast(title: String = "Error".localized(), message: String) {
        self.showToast(error: true, title: title, message: message)
    }
    
    func showSuccessToast(title: String = "Success".localized(), message: String) {
        self.showToast(error: false, title: title, message: message)
    }
    
    func getSyncEngine() -> SyncEngine? {
        return (UIApplication.shared.delegate as! AppDelegate).syncEngine
    }
}

class ClosureSleeve {
    let closure: () -> ()
    
    init(attachTo: AnyObject, closure: @escaping () -> ()) {
        self.closure = closure
        objc_setAssociatedObject(attachTo, "[\(arc4random())]", self, .OBJC_ASSOCIATION_RETAIN)
    }
    
    @objc func invoke() {
        self.closure()
    }
}

extension UIControl {
    func addAction(for controlEvents: UIControl.Event = .primaryActionTriggered, action: @escaping () -> ()) {
        let sleeve = ClosureSleeve(attachTo: self, closure: action)
        self.addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    static var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }
    static var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    }
    static var nextWeek: Date {
        return Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    }
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
    func showOK(title: String = Config.General.appName, message: String?) {
        Alert(title: title, message: message).showOK()
    }
    
    func showError(message: String) {
        Alert(title: "Error".localized(), message: message).showOK()
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

@IBDesignable
class LeftAlignedIconButton: UIButton {
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let titleRect = super.titleRect(forContentRect: contentRect)
        let imageSize = currentImage?.size ?? .zero
        let availableWidth = contentRect.width - imageEdgeInsets.right - imageSize.width - titleRect.width
        return titleRect.offsetBy(dx: round(availableWidth / 2), dy: 0)
    }
}

extension UITextView {
    var numberOfCurrentlyDisplayedLines: Int {
        let size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return Int(((size.height - layoutMargins.top - layoutMargins.bottom) / font!.lineHeight))
    }
    
    func removeTextUntilSatisfying(maxNumberOfLines: Int) {
        while numberOfCurrentlyDisplayedLines > (maxNumberOfLines) {
            text = String(text.dropLast())
            layoutIfNeeded()
        }
    }
}

extension Bundle {
    var releaseVersionNumber: String {
        return "\(infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
    }
    var buildVersionNumber: String {
        return "\(infoDictionary?["CFBundleVersion"] as? String ?? "")"
    }
}
