//
//  StampsTests.swift
//  StampsTests
//
//  Created by vlad on 3/20/17.
//  Copyright © 2017 908. All rights reserved.
//

import XCTest
@testable import Stamps
import AVFoundation

class CapturePhotoViewControllerTests: XCTestCase {
    var capturePhotoController: CapturePhotoViewController!
    
    override func setUp() {
        super.setUp()
        
        capturePhotoController = CapturePhotoViewController.storyboardController()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

        capturePhotoController = nil
    }

    func test_imagePickerDelegate_isSetToSelf_afterViewDidLoad() {
        // load view
        _ = capturePhotoController.view!

        XCTAssertTrue(capturePhotoController.imagePicker.delegate as? CapturePhotoViewController == capturePhotoController)
    }

    func test_cameraLayer_isAtTheBottom_afterViewDidLoad() {
        let view = capturePhotoController.view!

        let firstLayer = view.layer.sublayers!.first!
        
        XCTAssertTrue(firstLayer is AVCaptureVideoPreviewLayer)
    }

//    func test_imagePicker_shown_afterShowPhotoPickerButtonTapped() {
//        _ = capturePhotoController.view
//        capturePhotoController.showPhotoPickerTapped(UIButton())
//        XCTAssert(capturePhotoController.presentedViewController as? UIImagePickerController == capturePhotoController.imagePicker)
//    }

    func testChangeCameraButtonTapped() {
        let btn = UIButton()

        capturePhotoController.changeCameraButtonTapped(btn)

        XCTAssert(btn.isSelected == true)
    }
}
