//
//  RealmManager.swift
//  ToDoList
//
//  Created by Radu Ursache on 20/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit
import RealmSwift

class RealmManager {
    static let sharedInstance = RealmManager()
    
    private var realm: Realm
    
    private init() {
        let config = Realm.Configuration(schemaVersion: 6, migrationBlock: { migration, oldSchemaVersion in
            
        })
    
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
    
    func addTask(object: TaskModel) {
        self.addObject(object: object, update: false)
    }
    
    func updateTask(object: TaskModel) {
        self.addObject(object: object, update: true)
    }
    
    func changeTaskContent(object: TaskModel, content: String) {
        do {
            try realm.write {
                object.content = content
            }
        }
        catch {
            print("Realm error: Cannot write: \(object)")
        }
    }
    
    func changeTaskPriority(object: TaskModel, priority: Int) {
        do {
            try realm.write {
                object.priority = priority
            }
        }
        catch {
            print("Realm error: Cannot write: \(object)")
        }
    }
    
    func completeTask(object: TaskModel) {
        do {
            try realm.write {
                object.isCompleted = true
            }
        }
        catch {
            print("Realm error: Cannot write: \(object)")
        }
    }
    
    func deleteTask(object: TaskModel, soft: Bool = true) {
        if soft {
            self.softDeleteObject(object: object)
        } else {
            self.deleteObject(object: object)
        }
    }
    
    func updateComments(object: TaskModel, commentsToAdd: [CommentModel]) {
        do {
            try realm.write {
                for comment in commentsToAdd {
                    object.comments.append(comment)
                }
                realm.add(object, update: true)
            }
        }
        catch {
            print("Realm error: Cannot write: \(object)")
        }
    }
    
    // generic funcs
    
    func addObject(object: Object, update: Bool) {
        do {
            try realm.write {
                realm.add(object, update: update)
            }
        }
        catch {
            print("Realm error: Cannot write: \(object)")
        }
    }
    
    func deleteObject(object: Object) {
        do {
            try realm.write {
                realm.delete(object)
            }
        }
        catch {
            print("Realm error: Cannot write: \(object)")
        }
    }
    
    func softDeleteObject(object: TaskModel) {
        do {
            try realm.write {
                object.isDeleted = true
            }
        }
        catch {
            print("Realm error: Cannot write: \(object)")
        }
    }
    
    func compressImageData(imageData: NSData) -> NSData {
        if imageData.length > 16500000 {
            let image = UIImage(data: imageData as Data, scale: 0.7)
            
            let firstTry = image!.jpegData(compressionQuality: 0.7)! as NSData
            
            if firstTry.length > 16500000 {
                let image = UIImage(data: firstTry as Data, scale: 0.5)
                
                let secondTry = image!.jpegData(compressionQuality: 0.5)! as NSData
                
                return secondTry
            } else {
                return firstTry
            }
        } else {
            return imageData
        }
    }
}
