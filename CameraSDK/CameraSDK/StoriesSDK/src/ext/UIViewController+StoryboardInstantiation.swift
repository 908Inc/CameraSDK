//
//  UIViewController+StoryboardInstantiation.swift
//  iMsgStickerpipe
//
//  Created by vlad on 9/22/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit

public extension UIViewController {
    public static func storyboardController() -> Self {
        let frameworkBundle = Bundle(identifier: "com.908.CameraSDK")
        let storyboard = UIStoryboard(name: "Stories", bundle: frameworkBundle)
        
        return instantiateFromStoryboardHelper(storyboard: storyboard)
    }
    
    private class func instantiateFromStoryboardHelper<T>(storyboard: UIStoryboard) -> T    {
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! T
    }
}
