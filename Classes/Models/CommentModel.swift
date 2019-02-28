//
//  CommentModel.swift
//  ToDoList
//
//  Created by Radu Ursache on 21/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit
import RealmSwift
import IceCream

class CommentModel: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var content = ""
    @objc dynamic var date = NSDate.init()
    @objc dynamic var isDeleted = false
    @objc dynamic var task: TaskModel?
    @objc dynamic var taskId = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(title: String, date: Date) {
        self.init()
        
        self.content = title
        self.date = date as NSDate
    }
    
    func setTask(task: TaskModel) {
        self.task = task
        self.taskId = task.id
    }
}

extension CommentModel: CKRecordConvertible {
    
}

extension CommentModel: CKRecordRecoverable {
    
}
