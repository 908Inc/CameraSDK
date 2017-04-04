//
//  StampChooserViewControllerTests.swift
//  Stories
//
//  Created by vlad on 4/2/17.
//  Copyright © 2017 908. All rights reserved.
//

import XCTest
@testable import Stamps

class StampChooserViewControllerTests: XCTestCase {
    var sut: StampChooserViewController!
    
    override func setUp() {
        super.setUp()

        sut = StampChooserViewController.storyboardController()
    }
    
    override func tearDown() {
        super.tearDown()

        sut = nil
    }
}
