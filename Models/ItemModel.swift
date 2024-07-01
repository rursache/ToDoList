//
//  ItemModel.swift
//  ToDoList
//
//  Created by Radu Ursache on 01.07.2024.
//

import Foundation
import SwiftData

@Model
final class ItemModel: Identifiable {
    var name: String!
    var date: Date!
    
    init(name: String, date: Date = Date()) {
        self.name = name
        self.date = date
    }
}
