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
	
	enum VCs: String {
		case home = "homeVC"
		case tasks = "tasksVC"
		case editTask = "editTaskVC"
		case reminders = "remindersVC"
		case comments = "commentsVC"
		case settings = "settingsVC"
		case themes = "themeVC"
	}
    
    // generals
	
	func getViewController(viewController: VCs, storyBoardName: String = "Main") -> UIViewController {
		return UIStoryboard.init(name: storyBoardName, bundle: nil).instantiateViewController(withIdentifier: viewController.rawValue)
	}
    
    func userIsLoggedIniCloud() -> Bool {
        return FileManager.default.ubiquityIdentityToken != nil
    }
    
    func getSyncEngine() -> SyncEngine? {
		#if realApp
			return (UIApplication.shared.delegate as! AppDelegate).syncEngine
		#else
			return nil
		#endif
    }
    
    func setBadgeNumber(badgeNumber: Int) {
		#if realApp
			UIApplication.shared.applicationIconBadgeNumber = badgeNumber
		#endif
    }
    
    func getCurrentThemeColor() -> UIColor {
        return Config.General.themes[UserDefaults.standard.integer(forKey: Config.UserDefaults.theme)].color
    }
	
	func isIpad() -> Bool {
		return UIDevice.current.userInterfaceIdiom == .pad
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
    
    // toast
    
    func showErrorToast(viewController: UIViewController? = nil, message: String) {
        self.showToast(viewController: viewController, message: message, state: .error)
    }
    
    func showSuccessToast(viewController: UIViewController? = nil, message: String) {
        self.showToast(viewController: viewController, message: message, state: .success)
    }
    
    func showInfoToast(viewController: UIViewController? = nil, message: String) {
        self.showToast(viewController: viewController, message: message, state: .info)
    }
    
    fileprivate func showToast(viewController: UIViewController?, message: String, state: Loaf.State) {
		DispatchQueue.main.async {
			var vc = UIViewController()
			#if realApp
				vc = UIApplication.shared.topMostViewController()
			#endif
			if viewController != nil {
				vc = viewController!
			}
			
			Loaf.dismiss(sender: vc)
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				Loaf(message, state: state, location: .top, sender: vc).show()
				
				DispatchQueue.main.asyncAfter(deadline: .now() + Config.General.toastOnScreenTime) {
					Loaf.dismiss(sender: vc, animated: true)
				}
			}
		}
    }
    
    // notifications
    
    func addNotification(task: TaskModel, date: Date, text: String?, saveInRealm: Bool = true) {
        if Calendar.current.date(byAdding: .hour, value: 1, to: date)! < Date() || date < Date() {
            return
        }
        
        let realmNotification = NotificationModel(text: text ?? task.content, date: date)
        realmNotification.setTask(task: task)
        
		
		let notification = RobinNotification(identifier: realmNotification.identifier, body: realmNotification.text, trigger: .date(date, repeats: .none))
        notification.badge = 1
        notification.setUserInfo(value: task.content, forKey: "taskName")
        notification.setUserInfo(value: task.id, forKey: "taskId")
		
        if let _ = Robin.scheduler.schedule(notification: notification) {
            if saveInRealm {
                RealmManager.sharedInstance.addNotification(notification: realmNotification)
            }
            
            print("notification added - \(realmNotification.identifier) - \(Config.General.dateFormatter().string(from: date))")
        } else {
            print("failed to add notification")
			Robin.scheduler.printScheduled()
            print(Robin.scheduler.scheduledCount())
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
        Robin.scheduler.cancel(withIdentifier: notification.identifier)
        RealmManager.sharedInstance.deleteNotification(notification: notification)
        print("notification removed - \(notification.identifier)")
    }
    
    private func removeAllNotifications() {
		Robin.scheduler.cancelAll()
    }
    
    func removeAllNotificationsForTask(task: TaskModel) {
        for notification in task.availableNotifications() {
            self.removeNotificationWithId(identifier: notification.identifier)
        }
    }
    
    func addAllExistingNotifications() {
        self.removeAllNotifications()
        
        let allNotifications = RealmManager.sharedInstance.getAllNotifications()
        for notification in allNotifications {
            if let task = RealmManager.sharedInstance.getTaskById(id: notification.taskId) {
                self.addNotification(task: task, date: notification.date as Date, text: notification.text, saveInRealm: false)
            }
        }
//
//        let allTasks = RealmManager.sharedInstance.getTasks()
//        for task in allTasks {
//            for _ in task.availableNotifications() {
//                if let taskDate = task.date {
//                    self.addNotification(task: task, date: taskDate.next(minutes: Config.General.notificationDefaultDelayForNotifications), text: nil, saveInRealm: false)
//                }
//            }
//        }
    }
	
	func showAbout() {
		Alert(title: Config.General.appName, message: "SETTINGS_ABOUT_TEXT".localized() + "v\(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))").showOK()
	}
}
