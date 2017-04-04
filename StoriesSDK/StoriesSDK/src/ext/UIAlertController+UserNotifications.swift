//
//  UIAlertController+UserNotifications.swift
//  Stories
//
//  Created by vlad on 3/10/17.
//  Copyright © 2017 908. All rights reserved.
//

import UIKit

enum UserAlert {
    static let lIncorrectImage = Notification(title: "#*$#!", message: "We can't process this image. Try another one")
    static let lBrokenImage = Notification(title: "Ooops..", message: "Something wrong with this image. Try another one!")
    static let lNoFaceFound = Notification(title: "Ooops..", message: "We can't find your face on this image. Try another one")

    struct Notification {
        fileprivate let title: String
        fileprivate let message: String

        fileprivate init(title: String, message: String) {
            self.message = message
            self.title = title
        }
    }
}

extension UIAlertController {
    static func show(from controller: UIViewController, for alertNotification: UserAlert.Notification, logMessage: String? = nil) {
        _ = UIAlertController.show(from: controller, title: alertNotification.title, message: alertNotification.message)

        if let logMessage = logMessage {
            logToServer(message: logMessage)
        }
    }
}
