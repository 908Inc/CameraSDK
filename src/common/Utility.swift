//
//  Utility.swift
//  iMsgStickerpipe
//
//  Created by vlad on 9/28/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit

class Utility: NSObject {
    static let maxDensity = "xxhdpi"
    static let animatedDensity = "mdpi"

    private static var scale: String?
    static var scaleString: String {
        get {
            if scale == nil {
                switch UIScreen.main.scale {
                case 1:
                    scale = "mdpi"
                case 2:
                    scale = "xhdpi"
                case 3:
                    scale = "xxhdpi"
                default:
                    scale = "xxhdpi"
                }
            }

            return scale!
        }
    }

    static let defaultGreyColor = UIColor(
            colorLiteralRed: 229.0 / 255.0,
            green: 229.0 / 255.0,
            blue: 234.0 / 255.0,
            alpha: 1)

    static let defaultPlaceholderGrayColor = UIColor(
            colorLiteralRed: 142.0 / 255.0,
            green: 142.0 / 255.0,
            blue: 147.0 / 255.0,
            alpha: 1)
}
