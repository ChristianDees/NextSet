//
//  ExerciseTemplate+CoreDataProperties.swift
//  NextSet
//
//  Created by Christian Dees on 8/28/25.
//
//

import Foundation
import CoreData


extension ExerciseTemplate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseTemplate> {
        return NSFetchRequest<ExerciseTemplate>(entityName: "ExerciseTemplate")
    }

    @NSManaged public var name: String?
    @NSManaged public var exercises: NSSet?

}

// MARK: Generated accessors for exercises
extension ExerciseTemplate {

    @objc(addExercisesObject:)
    @NSManaged public func addToExercises(_ value: Exercise)

    @objc(removeExercisesObject:)
    @NSManaged public func removeFromExercises(_ value: Exercise)

    @objc(addExercises:)
    @NSManaged public func addToExercises(_ values: NSSet)

    @objc(removeExercises:)
    @NSManaged public func removeFromExercises(_ values: NSSet)

}

extension ExerciseTemplate : Identifiable {

}
