//
//  Seti+CoreDataProperties.swift
//  NextSet
//
//  Created by Christian Dees on 8/28/25.
//
//

import Foundation
import CoreData


extension Seti {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Seti> {
        return NSFetchRequest<Seti>(entityName: "Seti")
    }

    @NSManaged public var reps: Int16
    @NSManaged public var weight: Double
    @NSManaged public var timestamp: Date?
    @NSManaged public var exercise: Exercise?

}

extension Seti : Identifiable {

}
