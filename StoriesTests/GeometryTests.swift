//
//  GeometryTests.swift
//  Stories
//
//  Created by vlad on 3/28/17.
//  Copyright © 2017 908. All rights reserved.
//

import XCTest
@testable import Stamps

class GeometryTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    private func randomStartEndPoints() -> (CGPoint, CGPoint) {
        let x = CGFloat(arc4random() % 100)
        let y = CGFloat(arc4random() % 100)

        let offsetX = CGFloat(arc4random() % 100)
        let offsetY = CGFloat(arc4random() % 100)

        return (CGPoint(x: x, y: y), CGPoint(x: x + offsetX, y: y + offsetY))
    }

    private func randomRect() -> CGRect {
        let origin = randomStartEndPoints().0
        let randomSize = CGSize(width: CGFloat(arc4random() % 100), height: CGFloat(arc4random() % 100))

        return CGRect(origin: origin, size: randomSize)
    }

    func testLineInit() {
        let (start, end) = randomStartEndPoints()

        let line = Line(start: start, end: end)

        XCTAssertEqual(line.start, start)
        XCTAssertEqual(line.end, end)
    }

    func testLineCenter() {
        let (start, end) = randomStartEndPoints()

        let line = Line(start: start, end: end)

        let center = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)

        XCTAssertEqual(line.center, center)
    }

    func testLineLength() {
        let (start, end) = randomStartEndPoints()

        let line = Line(start: start, end: end)

        let length = sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2))

        XCTAssertEqual(line.length, length)
    }
}
