//
//  DatabaseActor.swift
//  ToDoList
//
//  Created by Radu Ursache on 01.07.2024.
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import Foundation
import SwiftData

actor DatabaseActor<T: PersistentModel> {
    var modelContainer: ModelContainer
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
}

/// MARK: Core logic
extension DatabaseActor {
    func insert(_ models: [T]) throws {
        let modelContext = ModelContext(modelContainer)
        for model in models {
            modelContext.insert(model)
        }
        try modelContext.save()
    }
    
    func delete(_ models: [T]) throws {
        let modelContext = ModelContext(modelContainer)
        for model in models {
            modelContext.delete(model)
        }
        try modelContext.save()
    }
    
    func delete(_ ids: [PersistentIdentifier]) throws {
        let modelContext = ModelContext(modelContainer)
        ids.compactMap { id in
            modelContext.model(for: id) as? T
        }.forEach { model in
            modelContext.delete(model)
        }
        try modelContext.save()
    }
    
    func fetch(predicate: Predicate<T>? = nil) throws -> [T] {
        let modelContext = ModelContext(modelContainer)
        var descriptor = FetchDescriptor<T>()
        if let predicate {
            descriptor.predicate = predicate
        }
        return try modelContext.fetch(descriptor)
    }
    
    func count(predicate: Predicate<T>? = nil) throws -> Int {
        let modelContext = ModelContext(modelContainer)
        var descriptor = FetchDescriptor<T>()
        if let predicate {
            descriptor.predicate = predicate
        }
        return try modelContext.fetchCount(descriptor)
    }
}

/// MARK: Helpers
extension DatabaseActor {
    func insert(_ model: T) throws {
        try insert([model])
    }
    
    func delete(_ model: T) throws {
        try delete([model])
    }
    
    func delete(_ id: PersistentIdentifier) throws {
        try delete([id])
    }
}
