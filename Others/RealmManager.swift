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
import IceCream

class RealmManager {
    static let sharedInstance = RealmManager()
    
    private var realm: Realm
    
    init() {
        var config = Realm.Configuration(schemaVersion: 14, migrationBlock: { migration, oldSchemaVersion in
            if oldSchemaVersion < 13 {
                migration.enumerateObjects(ofType: TaskModel.className()) { oldObject, newObject in
                    newObject!["completedDate"] = Date()
                }
            }
        })
		
		let fileManager = FileManager.default
		let realmPath = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.ro.randusoft.RSToDoList")!.path + "/db.realm"
		
		if let originalDefaultRealmPath = config.fileURL {
			if fileManager.fileExists(atPath: originalDefaultRealmPath.absoluteString) {
				do {
					try fileManager.moveItem(atPath: originalDefaultRealmPath.absoluteString, toPath: realmPath)
				} catch {
					print("error at moving default realm")
				}
			}
		}
		
		if let realmPathURL = URL(string: realmPath) {
			config.fileURL = realmPathURL
		} else {
			fatalError("bad realm path?")
		}
		
        self.realm = try! Realm(configuration: config)
    }
    
    static func sharedDelegate() -> RealmManager {
        return self.sharedInstance
    }
    
    // tasks
    
    func getTasks() -> Results<TaskModel> {
        let results: Results<TaskModel> = realm.objects(TaskModel.self)
        return results.filter("isDeleted == false").filter("isCompleted == false")
    }
    
    func getTodayTasks() -> Results<TaskModel> {
        return self.getTasks().filter("date BETWEEN %@", Utils().startEndDateArray(forDate: Date()))
    }
    
    func getTomorrowTasks() -> Results<TaskModel> {
        return self.getTasks().filter("date BETWEEN %@", Utils().startEndDateArray(forDate: Date.tomorrow))
    }
    
    func getWeekTasks() -> Results<TaskModel> {
        return self.getTasks().filter("date BETWEEN %@", [Date().startOfDay, Date.nextWeek.endOfDay])
    }
    
    func getCustomIntervalTasks(startDate: Date, endDate: Date) -> Results<TaskModel> {
        return self.getTasks().filter("date BETWEEN %@", [startDate.startOfDay, endDate.endOfDay])
    }
    
    func getCompletedTasks() -> Results<TaskModel> {
        return realm.objects(TaskModel.self).filter("isDeleted == false").filter("isCompleted == true")
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
            try realm.write {
                task.content = content
            }
        }
        catch {
            print("Realm error: Cannot write: \(task)")
        }
    }
    
    func changeTaskPriority(task: TaskModel, priority: Int) {
        do {
            try realm.write {
                task.priority = priority
            }
        }
        catch {
            print("Realm error: Cannot write: \(task)")
        }
    }
    
    func changeTaskDate(task: TaskModel, date: Date?) {
        do {
            try realm.write {
                task.date = date
            }
        }
        catch {
            print("Realm error: Cannot write: \(task)")
        }
    }
    
    func completeTask(task: TaskModel) {
        do {
            try realm.write {
                task.isCompleted = true
                task.completedDate = Date()
            }
        }
        catch {
            print("Realm error: Cannot write: \(task)")
        }
    }
    
    func unDoneTask(task: TaskModel) {
        do {
            try realm.write {
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
            try realm.write {
                task.isDeleted = true
            }
        }
        catch {
            print("Realm error: Cannot write: \(task)")
        }
    }
    
    func softUnDeleteTask(task: TaskModel) {
        do {
            try realm.write {
                task.isDeleted = false
            }
        }
        catch {
            print("Realm error: Cannot write: \(task)")
        }
    }
    
    // comments
    
    func getAllComments() -> Results<CommentModel> {
        let results: Results<CommentModel> = realm.objects(CommentModel.self)
        return results.filter("isDeleted == false")
    }
    
    func getCommentsForTaskId(taskId: String) -> Results<CommentModel> {
        return realm.objects(CommentModel.self).filter("taskId == '\(taskId)'").sorted(byKeyPath: "date", ascending: true)
    }
    
    func addComment(comment: CommentModel) {
        self.addObject(object: comment, update: true)
    }
    
    func setCommentTask(comment: CommentModel, task: TaskModel) {
        do {
            try realm.write {
                comment.task = task
            }
        }
        catch {
            print("Realm error: Cannot write: \(comment)")
        }
    }
    
    func changeCommentContent(comment: CommentModel, content: String) {
        do {
            try realm.write {
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
            try realm.write {
                comment.isDeleted = true
            }
        }
        catch {
            print("Realm error: Cannot write: \(comment)")
        }
    }
    
    // notifications
    
    func getAllNotifications() -> Results<NotificationModel> {
        let results: Results<NotificationModel> = realm.objects(NotificationModel.self)
        return results.filter("isDeleted == false")
    }
    
    func addNotification(notification: NotificationModel) {
        self.addObject(object: notification, update: false)
    }
    
    func getNotificationWithId(identifier: String) -> NotificationModel? {
        let results: Results<NotificationModel> = realm.objects(NotificationModel.self).filter("identifier == '\(identifier)'")
        if results.count == 1 {
            return results.first
        } else {
            return nil
        }
    }
    
    func getNotificationsForTaskId(taskId: String) -> Results<NotificationModel> {
        return realm.objects(NotificationModel.self).filter("taskId == '\(taskId)'").sorted(byKeyPath: "date", ascending: true)
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
            try realm.write {
                notification.isDeleted = true
            }
        }
        catch {
            print("Realm error: Cannot write: \(notification)")
        }
    }
    
    // generic private funcs
    
    private func addObject(object: Object, update: Bool) {
        do {
            try realm.write {
                realm.add(object, update: update ? .all : .modified)
            }
        }
        catch {
            print("Realm error: Cannot write: \(object)")
        }
    }
    
    private func deleteObject(object: Object) {
        do {
            try realm.write {
                realm.delete(object)
            }
        }
        catch {
            print("Realm error: Cannot write: \(object)")
        }
    }
}
