//
//  CapturePhotoHelperTests.swift
//  Stories
//
//  Created by vlad on 3/27/17.
//  Copyright © 2017 908. All rights reserved.
//

import XCTest
@testable import Stamps
import AVFoundation

class CapturePhotoHelperTests: XCTestCase {
    var capturePhotoHelper: CapturePhotoHelper!
    
    override func setUp() {
        super.setUp()
        
        capturePhotoHelper = CapturePhotoHelper()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_setCapturePositionBack() {
        capturePhotoHelper.setCaptureDeviceForPosition(.back)
        XCTAssert(capturePhotoHelper.captureDevice!.position == .back)
    }

    func test_setCapturePositionFront() {
        capturePhotoHelper.setCaptureDeviceForPosition(.front)
        XCTAssert(capturePhotoHelper.captureDevice!.position == .front)
    }

    func test_capturePhotoAsynchronously_back() {
        makePhoto(forPosition: .back)
    }

    func test_capturePhotoAsynchronously_front() {
        makePhoto(forPosition: .front)
    }

    func makePhoto(forPosition position: AVCaptureDevicePosition, line: UInt = #line) {
        let backPhotoExpectation = expectation(description: "Photo was made for \(position.rawValue)")

        capturePhotoHelper.setCaptureDeviceForPosition(position)

        capturePhotoHelper.capturePhotoAsynchronously { image, error in
            XCTAssertNil(error, line: line)
            XCTAssertNotNil(image, line: line)

            backPhotoExpectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }
}
