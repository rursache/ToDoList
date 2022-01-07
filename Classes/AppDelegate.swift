//
//  AppDelegate.swift
//  ToDoList
//
//  Created by Radu Ursache on 20/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit
import IceCream
import CloudKit
import Robin
import UserNotifications
import LKAlertController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var syncEngine: SyncEngine?
    var launchedShortcutItem: UIApplicationShortcutItem?
	var currentApplication: UIApplication?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
		self.currentApplication = application
		
        self.setupDefaults()
        
        self.setupSDKs()
        
        // check for 3d touch shortcuts
        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            self.launchedShortcutItem = shortcutItem
            
            return false
        }
        
        return true
    }
    
    func setupSDKs() {
        _ = RealmManager()
		
        self.syncEngine = SyncEngine(objects: [
			SyncObject(type: TaskModel.self),
			SyncObject(type: CommentModel.self),
			SyncObject(type: NotificationModel.self)
            ], databaseScope: .private)
    }
	
	func requestPushNotificationsPerms(handler: (() -> Void)? = nil) {
		Robin.settings.requestAuthorization(forOptions: [.alert, .badge, .sound]) { _, _ in
			DispatchQueue.main.async {
				handler?()
			}
		}
	}
    
    func setupDefaults() {
        let userDefaults = UserDefaults.standard
        
        if !userDefaults.bool(forKey: Config.UserDefaults.launchedBefore) {
            userDefaults.set(true, forKey: Config.UserDefaults.helpPrompts)
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        self.handleShortcuts(shortcutItem: shortcutItem)
        
        completionHandler(true)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        self.syncEngine?.pull()
		
//		NotificationCenter.default.post(name: Config.Notifications.shouldReloadData, object: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // handle 3d touch shortcuts
        if let shortcut = self.launchedShortcutItem {
            self.handleShortcuts(shortcutItem: shortcut)
            self.launchedShortcutItem = nil
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func handleShortcuts(shortcutItem: UIApplicationShortcutItem) {
        var option = 0
        
        if shortcutItem.type.contains("alltasks") {
            option = 1
        } else if shortcutItem.type.contains("today") {
            option = 2
        } else if shortcutItem.type.contains("tomorrow") {
            option = 3
        } else if shortcutItem.type.contains("newtask") {
            option = 0
        }
        
        NotificationCenter.default.post(name: Config.Notifications.threeDTouchShortcut, object: nil, userInfo: ["option": option])
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let dict = userInfo as! [String: NSObject]
        guard let notification = CKNotification(fromRemoteNotificationDictionary: dict) else {
            return
        }
        
        if (notification.subscriptionID == IceCreamSubscription.cloudKitPublicDatabaseSubscriptionID.rawValue) {
            NotificationCenter.default.post(name: Notifications.cloudKitDataDidChangeRemotely.name, object: nil, userInfo: userInfo)
        }
        
        completionHandler(.newData)
    }
    
    func handlePushNotification(userInfo: [AnyHashable : Any]) {
        guard let taskId = userInfo["taskId"] as? String,
            let taskName = userInfo["taskName"] as? String,
            let pushId = userInfo["RobinNotificationIdentifierKey"] as? String,
            let pushDate = userInfo["RobinNotificationDateKey"] as? Date else {
                print("push data invalid")
                return
        }
        
        print(taskId, taskName, pushId, pushDate)
        
        // show alert if in foreground
        if (UIApplication.shared.applicationState == .active) {
            Alert(title: "NOTIFICATION".localized(), message: taskName).showOK()
        }
        
        // remove this notificaton from realm
        Utils().removeNotificationWithId(identifier: pushId)
        
        // ask tasksviewcontroller to reload data
//        NotificationCenter.default.post(name: Config.Notifications.shouldReloadData, object: nil)
        
        // also open all tasks view
        NotificationCenter.default.post(name: Config.Notifications.threeDTouchShortcut, object: nil, userInfo: ["option": 1])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("push willPresent")
        
        // called in foreground
        
        self.handlePushNotification(userInfo: notification.request.content.userInfo)
        
        completionHandler(.sound)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
       
        print("push didReceive")
        
        // called on push tap
        
        self.handlePushNotification(userInfo: response.notification.request.content.userInfo)
        
        completionHandler()
    }
}

