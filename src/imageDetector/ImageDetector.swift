//
//  ImageDetector.swift
//  Stories
//
//  Created by vlad on 9/1/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit

enum ImageDetectorError: Error {
    case couldNotCreateDetector
}

class ImageDetector: NSObject {
    struct Emotion: Equatable {
        var leftWink: Bool
        var rightWink: Bool
        var smile: Bool

        static let noEmotion = Emotion(leftWink: false, rightWink: false, smile: false)

        public static func ==(lhs: Emotion, rhs: Emotion) -> Bool {
            return lhs.rightWink == rhs.rightWink && lhs.leftWink == rhs.leftWink && lhs.smile == rhs.smile
        }
    }

    static let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])

    static func getEmotion(from ciImage: CIImage) -> Emotion? {
        guard let detector = detector else {
            return nil
        }

        let features = detector.features(in: ciImage, options: [CIDetectorSmile: true, CIDetectorEyeBlink: true, CIDetectorImageOrientation: 5])

        guard features.count > 0 else {
            return nil
        }

        for feature in features {
            guard let faceFeature = feature as? CIFaceFeature else {
                continue
            }

            return Emotion(leftWink: faceFeature.leftEyeClosed, rightWink: faceFeature.rightEyeClosed, smile: faceFeature.hasSmile)
        }

        return nil
    }

    static func getCords(from image: CIImage, for rect: CGRect) throws -> [Face]? {
        guard let detector = detector else {
            throw ImageDetectorError.couldNotCreateDetector
        }

        let features = detector.features(in: image)

        guard features.count > 0 else {
            return nil
        }

        var faces = [Face]()

        let uiImage = UIImage(ciImage: image)

        let arY: CGFloat = uiImage.size.height / UIScreen.main.bounds.height
        let arX = arY

        let difference = (uiImage.size.width / arX - UIScreen.main.bounds.width) / 2

        let originalFace = Face(withRect: CGRect.zero)

        for feature in features {
            guard let faceFeature = feature as? CIFaceFeature else {
                continue
            }

            var faceBounds = faceFeature.bounds(forImage: uiImage)

            faceBounds.origin.y /= arY
            faceBounds.size.height /= arY
            faceBounds.size.width /= arX
            faceBounds.origin.x /= arX

            faceBounds.origin.x -= difference

            let stkFace = Face(withRect: faceBounds)

            if (faceFeature.hasLeftEyePosition) {
                let leftPosX = faceFeature.leftEyePosition(forImage: uiImage).x / arX - difference
                let leftPosY = faceFeature.leftEyePosition(forImage: uiImage).y / arY

                originalFace.leftEye = FaceObject(withRect: CGRect.zero, center: faceFeature.leftEyePosition(forImage: uiImage))

                stkFace.leftEye = FaceObject(withRect: CGRect.zero, center: CGPoint(x: leftPosX, y: leftPosY))
            }

            if (faceFeature.hasRightEyePosition) {
                let rightPosX = faceFeature.rightEyePosition(forImage: uiImage).x / arX - difference
                let rightPosY = faceFeature.rightEyePosition(forImage: uiImage).y / arY

                originalFace.rightEye = FaceObject(withRect: CGRect.zero, center: faceFeature.rightEyePosition(forImage: uiImage))

                stkFace.rightEye = FaceObject(withRect: CGRect.zero, center: CGPoint(x: rightPosX, y: rightPosY))
            }

            if (faceFeature.hasMouthPosition) {
                let mouthPosX = faceFeature.mouthPosition(forImage: uiImage).x / arX
                let mouthPosY = faceFeature.mouthPosition(forImage: uiImage).y / arY

                stkFace.mouth = FaceObject(withRect: CGRect.zero, center: CGPoint(x: mouthPosX, y: mouthPosY))
            }

            faces.append(stkFace)
        }

        return faces
    }
}
