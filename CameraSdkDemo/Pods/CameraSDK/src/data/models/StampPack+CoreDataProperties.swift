//
//  StampPack+CoreDataProperties.swift
//  
//
//  Created by vlad on 4/4/17.
//
//

import Foundation
import CoreData


extension StampPack {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StampPack> {
        return NSFetchRequest<StampPack>(entityName: "StampPack")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var orderNumber: Int16
    @NSManaged public var title: String?
    @NSManaged public var updatedAt: Int64
    @NSManaged public var stamps: NSSet?

}

// MARK: Generated accessors for stamps
extension StampPack {

    @objc(addStampsObject:)
    @NSManaged public func addToStamps(_ value: Stamp)

    @objc(removeStampsObject:)
    @NSManaged public func removeFromStamps(_ value: Stamp)

    @objc(addStamps:)
    @NSManaged public func addToStamps(_ values: NSSet)

    @objc(removeStamps:)
    @NSManaged public func removeFromStamps(_ values: NSSet)

}
