//
//  Event+CoreDataProperties.swift
//  
//
//  Created by vlad on 4/6/17.
//
//

import Foundation
import CoreData


extension Event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }

    @NSManaged public var action: String
    @NSManaged public var category: String
    @NSManaged public var label: Int32

}
