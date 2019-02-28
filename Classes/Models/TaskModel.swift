//
//  TaskModel.swift
//  ToDoList
//
//  Created by Radu Ursache on 21/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import IceCream
import CloudKit

class TaskModel: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var content = ""
    @objc dynamic var date: Date?
    @objc dynamic var priority = 10
    @objc dynamic var isDeleted = false
    @objc dynamic var isCompleted = false
    private let comments = LinkingObjects(fromType: CommentModel.self, property: "task")
    private let notifications = LinkingObjects(fromType: NotificationModel.self, property: "task")
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(title: String, date: Date?, priority: Int?) {
        self.init()
        
        self.content = title
        self.date = date
        if let priority = priority {
            self.priority = priority
        }
    }
    
    func availableComments() -> Results<CommentModel> {
        return self.comments.filter("isDeleted == false")
    }
    
    func availableNotifications() -> Results<NotificationModel> {
        return self.notifications.filter("isDeleted == false")
    }
}

extension TaskModel: CKRecordConvertible {
    
}

extension TaskModel: CKRecordRecoverable {
    
}
