//
//  Utils.swift
//  ToDoList
//
//  Created by Radu Ursache on 20/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit
import LKAlertController
import Loaf
import IceCream
import Robin

class Utils: NSObject {
    
    // generals
    
    func userIsLoggedIniCloud() -> Bool {
        return FileManager.default.ubiquityIdentityToken != nil
    }
    
    func getSyncEngine() -> SyncEngine? {
        return (UIApplication.shared.delegate as! AppDelegate).syncEngine
    }
    
    func setBadgeNumber(badgeNumber: Int) {
        UIApplication.shared.applicationIconBadgeNumber = badgeNumber
    }
    
    func getCurrentThemeColor() -> UIColor {
        return Config.General.themes[UserDefaults.standard.integer(forKey: Config.UserDefaults.theme)].color
    }
    
    // themes
    
    func themeView(view: UIView, setBackgroundColor: Bool = true) {
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        if setBackgroundColor {
            view.backgroundColor = self.getCurrentThemeColor()
        }
        
        if view is UIButton {
            (view as! UIButton).setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    // dates
    
    func startEndDateArray(forDate: Date) -> [Date] {
        return [forDate.startOfDay, forDate.endOfDay]
    }
    
    // toast
    
    func showErrorToast(viewController: UIViewController = UIApplication.shared.topMostViewController(), message: String) {
        self.showToast(viewController: viewController, message: message, state: .error)
    }
    
    func showSuccessToast(viewController: UIViewController = UIApplication.shared.topMostViewController(), message: String) {
        self.showToast(viewController: viewController, message: message, state: .success)
    }
    
    func showInfoToast(viewController: UIViewController = UIApplication.shared.topMostViewController(), message: String) {
        self.showToast(viewController: viewController, message: message, state: .info)
    }
    
    func showToast(viewController: UIViewController, message: String, state: Loaf.State) {
        Loaf.dismiss(sender: viewController)
        Loaf(message, state: state, sender: viewController).show()
    }
    
    // notifications
    
    func addNotification(task: TaskModel, date: Date, text: String?, saveInRealm: Bool = true) {
        if Calendar.current.date(byAdding: .hour, value: 1, to: date)! < Date() {
            return
        }
        
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
            
            print("notification added - \(realmNotification.identifier)")
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
        print("notification removed - \(notification.identifier)")
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
}
