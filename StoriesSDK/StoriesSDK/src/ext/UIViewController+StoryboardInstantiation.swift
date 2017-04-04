//
//  UIViewController+StoryboardInstantiation.swift
//  iMsgStickerpipe
//
//  Created by vlad on 9/22/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit

extension UIViewController {
    static func storyboardController() -> Self {
        return instantiateFromStoryboardHelper(storyboard: UIStoryboard(name: "Stories", bundle: Bundle.main))
    }
    
    private class func instantiateFromStoryboardHelper<T>(storyboard: UIStoryboard) -> T    {
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! T
    }
}
