//
//  Story+CoreDataProperties.swift
//  
//
//  Created by vlad on 4/4/17.
//
//

import Foundation
import CoreData


extension Story {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Story> {
        return NSFetchRequest<Story>(entityName: "Story")
    }

    @NSManaged public var dataHash: String?
    @NSManaged public var iconUrl: String?
    @NSManaged public var id: Int32
    @NSManaged public var orderNumber: Int16
    @NSManaged public var stamps: NSSet?

}

// MARK: Generated accessors for stamps
extension Story {

    @objc(addStampsObject:)
    @NSManaged public func addToStamps(_ value: StoryStamp)

    @objc(removeStampsObject:)
    @NSManaged public func removeFromStamps(_ value: StoryStamp)

    @objc(addStamps:)
    @NSManaged public func addToStamps(_ values: NSSet)

    @objc(removeStamps:)
    @NSManaged public func removeFromStamps(_ values: NSSet)

}
