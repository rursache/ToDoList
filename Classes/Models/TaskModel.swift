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
#if realApp
import IceCream
#endif
import CloudKit

class TaskModel: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var content = ""
    @objc dynamic var date: Date?
    @objc dynamic var completedDate: Date?
    @objc dynamic var priority = 10
    @objc dynamic var isDeleted = false
    @objc dynamic var isCompleted = false
    
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
        return RealmManager.sharedInstance.getCommentsForTaskId(taskId: self.id).filter("isDeleted == false")
    }
    
    func availableNotifications() -> Results<NotificationModel> {
        return RealmManager.sharedInstance.getNotificationsForTaskId(taskId: self.id).filter("isDeleted == false")
    }
}

#if realApp
extension TaskModel: CKRecordConvertible {

}

extension TaskModel: CKRecordRecoverable {

}
#endif
