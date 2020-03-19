//
//  RealmManager.swift
//  ToDoList
//
//  Created by Radu Ursache on 20/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

/*
 
 https://realm.io/docs/swift/latest
 
*/

import UIKit
import Realm
import RealmSwift
#if realApp
import IceCream
#endif
import WatchConnectivity

class RealmManager: NSObject {
    static let sharedInstance = RealmManager()
    
	private let realmVersion: UInt64 = 15
	private var realmConfig: Realm.Configuration
	private let realmPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ro.randusoft.RSToDoList")!.path + "/db.realm"
	
	private var wcSession: WCSession! = nil
    
	override init() {
        print("realmPath --- \(realmPath)")
		self.realmConfig = Realm.Configuration(schemaVersion: self.realmVersion, migrationBlock: { migration, oldSchemaVersion in
            if oldSchemaVersion < 13 {
                migration.enumerateObjects(ofType: TaskModel.className()) { oldObject, newObject in
                    newObject!["completedDate"] = Date()
                }
            }
			
			if oldSchemaVersion == 14 {
				migration.enumerateObjects(ofType: CommentModel.className()) { oldObject, newObject in
                    newObject!["imageData"] = NSData()
                }
			}
        })
		
		if let originalDefaultRealmPath = self.realmConfig.fileURL {
			if FileManager.default.fileExists(atPath: originalDefaultRealmPath.absoluteString) {
				do {
					try FileManager.default.moveItem(atPath: originalDefaultRealmPath.absoluteString, toPath: realmPath)
				} catch {
					print("error at moving default realm")
				}
			}
		}
		
		if let realmPathURL = URL(string: realmPath) {
			self.realmConfig.fileURL = realmPathURL
		} else {
			fatalError("bad realm path?")
		}
		
		super.init()
		
		self.activateWatch()
    }
	
	func watchInit() {
		guard let documentsPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
			print("watchInit: failed to get doc path")
			return
		}
		
		var config = Realm.Configuration(schemaVersion: self.realmVersion, migrationBlock: { migration, oldSchemaVersion in
            // we dont do migrations here
        })
		
		config.fileURL = documentsPathURL.appendingPathComponent("db.realm")
		
//		self.realm = try! Realm(configuration: config)
	}
	
    static func sharedDelegate() -> RealmManager {
        return self.sharedInstance
    }
	
	private func getRealm() -> Realm {
		return try! Realm(configuration: self.realmConfig)
	}
	
	fileprivate func activateWatch() {
		if !WCSession.isSupported() {
			return
		}
		
		self.wcSession = WCSession.default
		#if realApp
        self.wcSession.delegate = self
		#endif
        self.wcSession.activate()
		
		self.updateDbOnWatch()
	}
    
    // tasks
    
    func getTasks() -> Results<TaskModel> {
		let results: Results<TaskModel> = self.getRealm().objects(TaskModel.self)
        return results.filter("isDeleted == false").filter("isCompleted == false")
    }
    
    func getTodayTasks() -> Results<TaskModel> {
        return self.getTasks().filter("date BETWEEN %@", self.startEndDateArray(forDate: Date()))
    }
    
    func getTomorrowTasks() -> Results<TaskModel> {
        return self.getTasks().filter("date BETWEEN %@", self.startEndDateArray(forDate: Date.tomorrow))
    }
    
    func getWeekTasks() -> Results<TaskModel> {
        return self.getTasks().filter("date BETWEEN %@", [Date().startOfDay, Date.nextWeek.endOfDay])
    }
    
    func getCustomIntervalTasks(startDate: Date, endDate: Date) -> Results<TaskModel> {
        return self.getTasks().filter("date BETWEEN %@", [startDate.startOfDay, endDate.endOfDay])
    }
    
    func getCompletedTasks() -> Results<TaskModel> {
		return self.getRealm().objects(TaskModel.self).filter("isDeleted == false").filter("isCompleted == true")
    }
    
    func addTask(task: TaskModel) {
        self.addObject(object: task, update: false)
    }
    
    func updateTask(task: TaskModel) {
        self.addObject(object: task, update: true)
    }
    
    func getTaskById(id: String) -> TaskModel? {
        let results = self.getTasks().filter("id == '\(id)'")
        if results.count == 1 {
            return results.first
        } else {
            return nil
        }
    }
    
    func changeTaskContent(task: TaskModel, content: String) {
		do {
            try self.getRealm().write {
                task.content = content
            }
        }
        catch {
            print("Realm error: Cannot write: \(task)")
        }
    }
    
    func changeTaskPriority(task: TaskModel, priority: Int) {
		do {
            try self.getRealm().write {
                task.priority = priority
            }
        }
        catch {
            print("Realm error: Cannot write: \(task)")
        }
    }
    
    func changeTaskDate(task: TaskModel, date: Date?) {
		do {
            try self.getRealm().write {
                task.date = date
            }
        }
        catch {
            print("Realm error: Cannot write: \(task)")
        }
    }
    
    func completeTask(task: TaskModel) {
		do {
            try self.getRealm().write {
                task.isCompleted = true
                task.completedDate = Date()
            }
			
			self.updateDbOnWatch()
        }
        catch {
            print("Realm error: Cannot write: \(task)")
        }
    }
    
    func unDoneTask(task: TaskModel) {
		do {
            try self.getRealm().write {
                task.isCompleted = false
                task.completedDate = nil
            }
        }
        catch {
            print("Realm error: Cannot write: \(task)")
        }
    }
    
    func deleteTask(task: TaskModel, soft: Bool = true) {
        if soft {
            self.softDeleteTask(task: task)
        } else {
            self.deleteObject(object: task)
        }
    }
    
    func softDeleteTask(task: TaskModel) {
        do {
            try self.getRealm().write {
                task.isDeleted = true
            }
        }
        catch {
            print("Realm error: Cannot write: \(task)")
        }
    }
    
    func softUnDeleteTask(task: TaskModel) {
        do {
            try self.getRealm().write {
                task.isDeleted = false
            }
        }
        catch {
            print("Realm error: Cannot write: \(task)")
        }
    }
    
    // comments
    
    func getAllComments() -> Results<CommentModel> {
        let results: Results<CommentModel> = self.getRealm().objects(CommentModel.self)
        return results.filter("isDeleted == false")
    }
    
    func getCommentsForTaskId(taskId: String) -> Results<CommentModel> {
        return self.getRealm().objects(CommentModel.self).filter("taskId == '\(taskId)'").sorted(byKeyPath: "date", ascending: true)
    }
    
    func addComment(comment: CommentModel) {
        self.addObject(object: comment, update: true)
    }
    
    func setCommentTask(comment: CommentModel, task: TaskModel) {
        do {
            try self.getRealm().write {
                comment.task = task
            }
        }
        catch {
            print("Realm error: Cannot write: \(comment)")
        }
    }
    
    func changeCommentContent(comment: CommentModel, content: String) {
        do {
            try self.getRealm().write {
                comment.content = content
            }
        }
        catch {
            print("Realm error: Cannot write: \(comment)")
        }
    }
    
    func deleteComment(comment: CommentModel, soft: Bool = true) {
        if soft {
            self.softDeleteComment(comment: comment)
        } else {
            self.deleteObject(object: comment)
        }
    }
    
    func softDeleteComment(comment: CommentModel) {
        do {
            try self.getRealm().write {
                comment.isDeleted = true
            }
        }
        catch {
            print("Realm error: Cannot write: \(comment)")
        }
    }
    
    // notifications
    
    func getAllNotifications() -> Results<NotificationModel> {
        let results: Results<NotificationModel> = self.getRealm().objects(NotificationModel.self)
        return results.filter("isDeleted == false")
    }
    
    func addNotification(notification: NotificationModel) {
        self.addObject(object: notification, update: false)
    }
    
    func getNotificationWithId(identifier: String) -> NotificationModel? {
        let results: Results<NotificationModel> = self.getRealm().objects(NotificationModel.self).filter("identifier == '\(identifier)'")
        if results.count == 1 {
            return results.first
        } else {
            return nil
        }
    }
    
    func getNotificationsForTaskId(taskId: String) -> Results<NotificationModel> {
        return self.getRealm().objects(NotificationModel.self).filter("taskId == '\(taskId)'").sorted(byKeyPath: "date", ascending: true)
    }
    
    func deleteNotification(notification: NotificationModel, soft: Bool = true) {
        if soft {
            self.softDeleteNotification(notification: notification)
        } else {
            self.deleteObject(object: notification)
        }
    }
    
    func softDeleteNotification(notification: NotificationModel) {
        do {
            try self.getRealm().write {
                notification.isDeleted = true
            }
        }
        catch {
            print("Realm error: Cannot write: \(notification)")
        }
    }
    
    // generic private funcs
    
    private func addObject(object: Object, update: Bool) {
		let realm = self.getRealm()
        do {
            try realm.write {
                realm.add(object, update: update ? .all : .modified)
            }
			
			self.updateDbOnWatch()
        }
        catch {
            print("Realm error: Cannot write: \(object)")
        }
    }
    
    private func deleteObject(object: Object) {
		let realm = self.getRealm()
        do {
            try realm.write {
                realm.delete(object)
            }
			
			self.updateDbOnWatch()
        }
        catch {
            print("Realm error: Cannot write: \(object)")
        }
    }
	
	// watch stuff
	fileprivate func updateDbOnWatch() {
		if !WCSession.isSupported() {
			return
		}
		
		guard let realmDBdata = try? Data(contentsOf: URL(fileURLWithPath: self.realmPath)) else {
			print("updateDbOnWatch: failed to read file?")
			return
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
			if !self.wcSession.isReachable {
				#if realApp
				if !self.wcSession.isPaired || !self.wcSession.isWatchAppInstalled {
					return
				}
				#endif
				
				self.wcSession.activate()
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
					self.updateDbOnWatch()
				}
				return
			}
			
			self.wcSession.sendMessageData(realmDBdata, replyHandler: { data in
				print("updateDbOnWatch: done")
			}) { error in
				print("updateDbOnWatch:", error.localizedDescription)
			}
		}
	}
	
	fileprivate func processMessage(dict: [String : Any]) {
		if let _ = dict["taskId"] as? String {
			#if realApp
			NotificationCenter.default.post(name: Config.Notifications.completeTask, object: nil, userInfo: dict)
			#endif
			self.updateDbOnWatch()
		}
	}
	
	// utils
	
	func getConfig() -> Realm.Configuration {
		return self.realmConfig
	}
	
	fileprivate func startEndDateArray(forDate: Date) -> [Date] {
        return [forDate.startOfDay, forDate.endOfDay]
    }
}

#if realApp
extension RealmManager: WCSessionDelegate {
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		print("iOS: watch session is \(activationState.rawValue)")
		self.updateDbOnWatch()
	}
	
	func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
		self.processMessage(dict: message)
		
		replyHandler(message)
	}
	
	func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
		self.processMessage(dict: message)
	}
	
	func sessionDidBecomeInactive(_ session: WCSession) {
		print("iOS: watch session inactive")
	}
	
	func sessionDidDeactivate(_ session: WCSession) {
		print("iOS: watch session did deactivate")
	}
}
#endif
