//
//  UIAlertController+ShortMessage.swift
//  Fonta
//
//  Created by vlad on 3/8/17.
//  Copyright © 2017 com.hatcom. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    static func show(from controller: UIViewController, title: String? = nil, message: String? = nil, actions: [UIAlertAction]? = nil) -> UIAlertController {
        let actionsToAdd = actions ?? [UIAlertAction.defaultActionWithTitle("Ok")]

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        for action in actionsToAdd {
            alert.addAction(action)
        }

        controller.present(alert, animated: true)

        return alert
    }
}

extension UIAlertAction {
    static func defaultActionWithTitle(_ title: String, action: (() -> ())? = nil) -> UIAlertAction {
        return UIAlertAction(title: title, style: .default) { alertAction in
            action?()
        }
    }
}
