//
//  StoryStamp+CoreDataProperties.swift
//  
//
//  Created by vlad on 4/4/17.
//
//

import Foundation
import CoreData


extension StoryStamp {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoryStamp> {
        return NSFetchRequest<StoryStamp>(entityName: "StoryStamp")
    }

    @NSManaged public var id: Int32
    @NSManaged public var imageUrl: String?
    @NSManaged public var orderNumber: Int16
    @NSManaged public var pointsContainer: StampPositionPointsContainer?
    @NSManaged public var position: String?
    @NSManaged public var rotation: Float
    @NSManaged public var scale: Float
    @NSManaged public var type: String?
    @NSManaged public var story: Story?

}
