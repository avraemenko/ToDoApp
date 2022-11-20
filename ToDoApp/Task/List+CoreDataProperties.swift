//
//  List+CoreDataProperties.swift
//  ToDoApp
//
//  Created by Kateryna Avramenko on 19.11.22.
//
//

import Foundation
import CoreData


extension List {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<List> {
        return NSFetchRequest<List>(entityName: "List")
    }

    @NSManaged public var title: String?
    @NSManaged public var subtasks: NSSet?

}

// MARK: Generated accessors for subtasks
extension List {

    @objc(addSubtasksObject:)
    @NSManaged public func addToSubtasks(_ value: Task)

    @objc(removeSubtasksObject:)
    @NSManaged public func removeFromSubtasks(_ value: Task)

    @objc(addSubtasks:)
    @NSManaged public func addToSubtasks(_ values: NSSet)

    @objc(removeSubtasks:)
    @NSManaged public func removeFromSubtasks(_ values: NSSet)

}

extension List : Identifiable {

}
