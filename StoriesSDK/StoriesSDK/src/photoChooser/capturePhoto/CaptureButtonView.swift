//
//  CaptureButtonView.swift
//  Stories
//
//  Created by vlad on 3/27/17.
//  Copyright © 2017 908. All rights reserved.
//

import UIKit

class CaptureButtonView: UIView, CapturePhotoHelperDelegate {
    private var numberOfEmotionChanges = 0

    func faceObjectsAppeared(_ emotion: ImageDetector.Emotion?) {
        DispatchQueue.main.async {
            if let emotion = emotion {
                if emotion.smile {
                    self.numberOfEmotionChanges = 0

                    self.label.isHidden = false
                } else if self.numberOfEmotionChanges == 5 {
                    self.numberOfEmotionChanges = 0

                    self.label.isHidden = true
                } else {
                    self.numberOfEmotionChanges += 1
                }

                self.captureButton.isSelected = true
            } else {
                self.label.isHidden = true

                self.captureButton.isSelected = false
            }
        }
    }


    @IBOutlet fileprivate weak var captureButton: UIButton!
    @IBOutlet fileprivate weak var label: UILabel!
}
