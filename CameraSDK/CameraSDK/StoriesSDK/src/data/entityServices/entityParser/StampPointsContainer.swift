//
//  StampPointsContainer.swift
//  Stories
//
//  Created by vlad on 3/30/17.
//  Copyright © 2017 908. All rights reserved.
//

import UIKit


public class StampPositionPointsContainer: NSObject, NSCoding {
    let points: [CGPoint]

    init(dicts: [[String: Any]]) {
        var points = [CGPoint]()

        for dict in dicts {
            guard let x = dict["x"] as? Int else {
                printErr("unknown format in points array; no x provided", logToServer: true)

                continue
            }

            guard let y = dict["y"] as? Int else {
                printErr("unknown format in points array; no y provided", logToServer: true)

                continue
            }

            points.append(CGPoint(x: x, y: y))
        }

        self.points = points
    }


    // MARK: NSCoding

    public func encode(with aCoder: NSCoder) {
        let pointValues = points.map {
            NSValue(cgPoint: $0)
        }

        aCoder.encode(pointValues, forKey: #keyPath(StoryStamp.pointsContainer))
    }

    public required init?(coder aDecoder: NSCoder) {
        guard let pointValues = aDecoder.decodeObject(forKey: #keyPath(StoryStamp.pointsContainer)) as? [NSValue] else {
            printErr("stored data is broken")

            return nil
        }

        points = pointValues.map {
            $0.cgPointValue
        }
    }
}
