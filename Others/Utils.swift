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
    
    func showErrorToast(title: String = "Error".localized(), message: String) {
        INNotifications.show(type: .danger, data: INNotificationData(title: title, description: message), position: .bottom)
    }
    
    func showSuccessToast(title: String = "Success".localized(), message: String) {
        INNotifications.show(type: .success, data: INNotificationData(title: title, description: message), position: .bottom)
    }
    
    // notifications
    
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
    
    // realm
    
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
}
