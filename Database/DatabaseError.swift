//
//  DatabaseError.swift
//  ToDoList
//
//  Created by Radu Ursache on 01.07.2024.
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import Foundation
import SwiftData

enum DatabaseError: Error {
    case objectNotFound(objectId: PersistentIdentifier)
}

extension DatabaseError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .objectNotFound(let id):
                "The object with id `\(id)` was not found in the database"
        }
    }
}
