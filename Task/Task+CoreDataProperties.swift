//
//  Task+CoreDataProperties.swift
//  ToDoApp
//
//  Created by Kateryna Avramenko on 20.11.22.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var title: String?
    @NSManaged public var note: String?
    @NSManaged public var done: Bool
    @NSManaged public var dateOfCreation: Date?
    @NSManaged public var isOpened: Bool
    @NSManaged public var subtasks: NSSet?
    @NSManaged public var supertask: Task?

    var subs: [Task] {
        guard let subtasks = self.subtasks else { return [] }
        return (subtasks.allObjects as? [Task]) ?? []
    }

}



// MARK: Generated accessors for subtasks
extension Task {

    @objc(addSubtasksObject:)
    @NSManaged public func addToSubtasks(_ value: Task)

    @objc(removeSubtasksObject:)
    @NSManaged public func removeFromSubtasks(_ value: Task)

    @objc(addSubtasks:)
    @NSManaged public func addToSubtasks(_ values: NSSet)

    @objc(removeSubtasks:)
    @NSManaged public func removeFromSubtasks(_ values: NSSet)

}

extension Task : Identifiable {

}
