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
import CloudKit

class CommentModel: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var content = ""
    @objc dynamic var date = NSDate.init()
    @objc dynamic var isDeleted = false
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(title: String, date: Date) {
        self.init()
        
        self.content = title
        self.date = date as NSDate
    }
}

extension CommentModel: CKRecordConvertible {
    
}

extension CommentModel: CKRecordRecoverable {
    
}
