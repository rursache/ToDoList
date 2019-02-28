//
//  Utils.swift
//  ToDoList
//
//  Created by Radu Ursache on 20/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit
import LKAlertController
import ImpressiveNotifications
import IceCream
import Robin

class Utils: NSObject {
    func themeView(view: UIView, setBackgroundColor: Bool = true) {
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        if setBackgroundColor {
            view.backgroundColor = Config.General.themes[UserDefaults.standard.integer(forKey: Config.UserDefaults.theme)].color
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
    
    func showErrorToast(title: String = "Error".localized(), message: String) {
        INNotifications.show(type: .danger, data: INNotificationData(title: title, description: message), position: .bottom)
    }
    
    func showSuccessToast(title: String = "Success".localized(), message: String) {
        INNotifications.show(type: .success, data: INNotificationData(title: title, description: message), position: .bottom)
    }
    
    func getSyncEngine() -> SyncEngine? {
        return (UIApplication.shared.delegate as! AppDelegate).syncEngine
    }
    
    func addNotification(task: TaskModel, date: Date, text: String?, saveInRealm: Bool = true) {
        let realmNotification = NotificationModel(text: text ?? task.content, date: date)
        realmNotification.setTask(task: task)
        
        let notification = RobinNotification(identifier: realmNotification.identifier, body: realmNotification.text, date: date)
        notification.badge = 1
        notification.setUserInfo(value: task.content, forKey: "taskName")
        notification.setUserInfo(value: task.id, forKey: "taskId")
        
        if let _ = Robin.shared.schedule(notification: notification) {
            if saveInRealm {
                RealmManager.sharedInstance.addNotification(notification: realmNotification)
            }
            
            print("notification added")
        } else {
            print("failed to add notification")
            Robin.shared.printScheduled()
            print(Robin.shared.scheduledCount())
        }
    }
    
    func removeNotificationWithId(identifier: String) {
        if let notification = RealmManager.sharedInstance.getNotificationWithId(identifier: identifier) {
            self.removeNotification(notification: notification)
        } else {
            print("cannot remove notification with id \(identifier)")
        }
    }
    
    func removeNotification(notification: NotificationModel) {
        Robin.shared.cancel(withIdentifier: notification.identifier)
        RealmManager.sharedInstance.deleteNotification(notification: notification)
    }
    
    private func removeAllNotifications() {
        Robin.shared.cancelAll()
    }
    
    func removeAllNotificationsForTask(task: TaskModel) {
        for notification in task.availableNotifications() {
            self.removeNotificationWithId(identifier: notification.identifier)
        }
    }
    
    func addAllExistingNotifications() {
        self.removeAllNotifications()
        
        let allTasks = RealmManager.sharedInstance.getTasks()
        for task in allTasks {
            for _ in task.availableNotifications() {
                if let taskDate = task.date {
                    self.addNotification(task: task, date: taskDate.next(minutes: Config.General.notificationDefaultDelayForNotifications), text: nil, saveInRealm: false)
                }
            }
        }
    }
    
    func checkTasksForNilObjects() {
        // https://github.com/caiyue1993/IceCream/issues/95#issuecomment-466779513
        
        print("iCloud Sync: Started recovery process")
        print("iCloud Sync: Found \(RealmManager.sharedInstance.getAllComments().count) comments")
        print("iCloud Sync: Found \(RealmManager.sharedInstance.getAllNotifications().count) notifications")
        
        var itemsRecovered = 0
        
        for comment in RealmManager.sharedInstance.getAllComments() {
            if comment.task == nil {
                if let recoveredTask = RealmManager.sharedInstance.getTaskById(id: comment.taskId) {
                    print("iCloud Sync: Recovered task-less comment (Text: \(comment.content), Recovered task ID: \(comment.taskId))")
                    
                    RealmManager.sharedInstance.setCommentTask(comment: comment, task: recoveredTask)
                    itemsRecovered += 1
                } else {
                    print("iCloud Sync: Failed to recover comment \(comment.id)")
                }
            }
        }
        for notification in RealmManager.sharedInstance.getAllNotifications() {
            if notification.task == nil {
                if let recoveredTask = RealmManager.sharedInstance.getTaskById(id: notification.taskId) {
                    print("iCloud Sync: Recovered task-less notification (Text: \(notification.text), Recovered task ID: \(notification.taskId))")
                    
                    RealmManager.sharedInstance.setNotificationTask(notification: notification, task: recoveredTask)
                    itemsRecovered += 1
                } else {
                    print("iCloud Sync: Failed to recover notification \(notification.identifier)")
                }
            }
        }
        
        print("iCloud Sync: Recovery done, \(itemsRecovered) items restored")
    }
    
    func setBadgeNumber(badgeNumber: Int) {
        UIApplication.shared.applicationIconBadgeNumber = badgeNumber
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

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
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
