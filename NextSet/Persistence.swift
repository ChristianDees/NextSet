//
//  Persistence.swift
//  NextSet
//
//  Created by Christian Dees on 8/28/25.
//

import CoreData


struct PersistenceController {
    
    static let shared = PersistenceController() // Shared instance for app

    let container: NSPersistentContainer    // Holds core data stack

    // Controller initialize, optionally using an in-memory store
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "NextSetModel")  // Initialize with the model name
        // Use an in-memory store for testing or previews
        if inMemory { container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null") }

        // Load the persistent stores
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("Unresolved error: \(error)") }
        }
    }
}

