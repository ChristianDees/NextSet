//
//  Exercise+CoreDataProperties.swift
//  NextSet
//
//  Created by Christian Dees on 8/28/25.
//
//

import Foundation
import CoreData


extension Exercise {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercise> {
        return NSFetchRequest<Exercise>(entityName: "Exercise")
    }

    @NSManaged public var date: Date?
    @NSManaged public var name: String?
    @NSManaged public var sets: NSSet?
    @NSManaged public var workout: Workout?
    @NSManaged public var template: ExerciseTemplate?

}

// MARK: Generated accessors for sets
extension Exercise {

    @objc(addSetsObject:)
    @NSManaged public func addToSets(_ value: Seti)

    @objc(removeSetsObject:)
    @NSManaged public func removeFromSets(_ value: Seti)

    @objc(addSets:)
    @NSManaged public func addToSets(_ values: NSSet)

    @objc(removeSets:)
    @NSManaged public func removeFromSets(_ values: NSSet)

}
