//
//  Item.swift
//  ToDoList
//
//  Created by Radu Ursache on 01.07.2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
