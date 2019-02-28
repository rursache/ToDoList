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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.syncEngine = SyncEngine(objects: [
            SyncObject<TaskModel>(),
            SyncObject<CommentModel>(),
            SyncObject<NotificationModel>()
            ])
        
        Robin.shared.requestAuthorization()
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        application.registerForRemoteNotifications()
        
        return true
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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let dict = userInfo as! [String: NSObject]
        let notification = CKNotification(fromRemoteNotificationDictionary: dict)
        
        if (notification.subscriptionID == IceCreamConstant.cloudKitSubscriptionID) {
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
            Alert(title: "Notification".localized(), message: taskName).showOK()
        }
        
        // remove this notificaton from realm
        Utils().removeNotificationWithId(identifier: pushId)
        
        // ask tasksviewcontroller to reload data
        NotificationCenter.default.post(name: Config.Notifications.shouldReloadData, object: nil)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("push willPresent")
        
        // called in foreground
        
        self.handlePushNotification(userInfo: notification.request.content.userInfo)
        
        completionHandler(.badge)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
       
        print("push didReceive")
        
        // called on push tap
        
        self.handlePushNotification(userInfo: response.notification.request.content.userInfo)
        
        completionHandler()
    }
}

