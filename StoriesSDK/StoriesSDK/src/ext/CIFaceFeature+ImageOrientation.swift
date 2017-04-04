//
//  CIFaceFeature+ImageOrientation.swift
//  Stories
//
//  Created by vlad on 4/3/17.
//  Copyright © 2017 908. All rights reserved.
//

import Foundation
import UIKit

extension CIFaceFeature {
    func leftEyePosition(forImage image: UIImage) -> CGPoint {
        return point(forImage: image, from: leftEyePosition)
    }

    func rightEyePosition(forImage image: UIImage) -> CGPoint {
        return point(forImage: image, from: rightEyePosition)
    }

    func mouthPosition(forImage image: UIImage) -> CGPoint {
        return point(forImage: image, from: mouthPosition)
    }

    func bounds(forImage image: UIImage) -> CGRect {
        return bounds(forImage: image, from: bounds)
    }

    private func point(forImage image: UIImage, from originalPoint: CGPoint) -> CGPoint {
        let imageWidth = image.size.width
        let imageHeight = image.size.height

        var convertedPoint = CGPoint()

        switch image.imageOrientation {
        case .up:
            convertedPoint.x = originalPoint.x
            convertedPoint.y = imageHeight - originalPoint.y
        case .down:
            convertedPoint.x = imageWidth - originalPoint.x
            convertedPoint.y = originalPoint.y
        case .left:
            convertedPoint.x = imageWidth - originalPoint.y
            convertedPoint.y = imageHeight - originalPoint.x
        case .right:
            convertedPoint.x = originalPoint.y
            convertedPoint.y = originalPoint.x
        case .upMirrored:
            convertedPoint.x = imageWidth - originalPoint.x
            convertedPoint.y = imageHeight - originalPoint.y
        case .downMirrored:
            convertedPoint.x = originalPoint.x
            convertedPoint.y = originalPoint.y
        case .leftMirrored:
            convertedPoint.x = imageWidth - originalPoint.y
            convertedPoint.y = originalPoint.x
        case .rightMirrored:
            convertedPoint.x = originalPoint.y
            convertedPoint.y = imageHeight - originalPoint.x
        default:()
        }
        return convertedPoint
    }

    func size(forImage image: UIImage, from originalSize: CGSize) -> CGSize {
        var convertedSize = CGSize()

        switch image.imageOrientation {
        case .up:fallthrough
        case .down:fallthrough
        case .upMirrored:fallthrough
        case .downMirrored:
            convertedSize.width = originalSize.width
            convertedSize.height = originalSize.height
        case .left:fallthrough
        case .right:fallthrough
        case .leftMirrored:fallthrough
        case .rightMirrored:fallthrough
            convertedSize.width = originalSize.height
            convertedSize.height = originalSize.width
        default:()
        }
        return convertedSize
    }

    func bounds(forImage image: UIImage, from originalBounds: CGRect) -> CGRect {
        var convertedOrigin = point(forImage: image, from: originalBounds.origin)
        let convertedSize = size(forImage: image, from: originalBounds.size)

        switch image.imageOrientation {
        case .up:
            convertedOrigin.y -= convertedSize.height
        case .down:
            convertedOrigin.x -= convertedSize.width
        case .left:
            convertedOrigin.x -= convertedSize.width
            convertedOrigin.y -= convertedSize.height
        case .right:()
        case .upMirrored:
            convertedOrigin.y -= convertedSize.height
            convertedOrigin.x -= convertedSize.width
        case .downMirrored:()
        case .leftMirrored:
            convertedOrigin.x -= convertedSize.width
            convertedOrigin.y += convertedSize.height
        case .rightMirrored:
            convertedOrigin.y -= convertedSize.height
        default:()
        }

        return CGRect(x: convertedOrigin.x, y: convertedOrigin.y, width: convertedSize.width, height: convertedSize.height)
    }
}
