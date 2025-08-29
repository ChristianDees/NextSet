//
//  Persistence.swift
//  NextStep
//
//  Created by Christian Dees on 8/28/25.
//

import CoreData

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "NextStepModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error: \(error)")
            }
        }
    }
}
extension PersistenceController {
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)

        // Example data for preview
        let context = controller.container.viewContext
        let exampleExercise = Exercise(context: context)
        exampleExercise.name = "Preview Bench Press"
        exampleExercise.date = Date()

        let set1 = Seti(context: context)
        set1.weight = 135
        set1.reps = 10
        set1.exercise = exampleExercise

        let set2 = Seti(context: context)
        set2.weight = 145
        set2.reps = 8
        set2.exercise = exampleExercise

        do {
            try context.save()
        } catch {
            fatalError("Unresolved error \(error)")
        }

        return controller
    }()
}
