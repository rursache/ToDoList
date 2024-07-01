//
//  HomeViewModel.swift
//  ToDoList
//
//  Created by Radu Ursache on 01.07.2024.
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import Foundation
import SwiftData

class TaskViewModel: ObservableObject {
    func deleteItemModels(_ tasks: [TaskModel], at offsets: IndexSet, modelContext: ModelContext) {
        let itemsToDelete = offsets.compactMap { tasks[$0].id }
        DatabaseManager.shared.delete(itemsToDelete, in: modelContext.container)
    }
    
    func addItemModel(modelContext: ModelContext) {
        DatabaseManager.shared.insert(TaskModel(name: "test"), in: modelContext.container)
    }
}
