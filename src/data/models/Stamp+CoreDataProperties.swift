//
//  Stamp+CoreDataProperties.swift
//  
//
//  Created by vlad on 4/4/17.
//
//

import Foundation
import CoreData


extension Stamp {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stamp> {
        return NSFetchRequest<Stamp>(entityName: "Stamp")
    }

    @NSManaged public var id: Int32
    @NSManaged public var imageUrl: String?
    @NSManaged public var name: String?
    @NSManaged public var orderNumber: Int16
    @NSManaged public var pack: StampPack?

}
