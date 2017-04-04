//
//  GlobalHelper.swift
//  Stories
//
//  Created by vlad on 10/12/16.
//  Copyright © 2016 908. All rights reserved.
//

import Foundation
import UIKit

typealias SimpleBlock = () -> ()
typealias StringBlock = (String) -> ()
typealias BoolBlock = (Bool) -> ()
typealias PointBlock = (CGPoint) -> ()

func printErr(_ textError: String, logToServer: Bool = false, error: Error? = nil, functionName f: String = #function, file: String = #file) {
    var errorLocation = f

    if let className = URL(string: file)?.lastPathComponent {
        errorLocation += ", \(className)"
    }

#if DEBUG

    if let error = error {
        print("Error in \(errorLocation) - \(error); \(textError)")
    } else {
        print("Error in \(errorLocation); \(textError)")
    }

#else

    guard logToServer else {
        return
    }

    if let error = error {
        Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["errorLocation": errorLocation, "textError": textError])
    } else {
        Crashlytics.sharedInstance().recordError(NSError(domain: "Stories.UnknownError", code: 0), withAdditionalUserInfo: ["errorLocation": errorLocation, "textError": textError])
    }

#endif
}

func logToServer(message: String, error: Error = NSError(domain: "Stories.UnknownError", code: 0), additionalInfo: [String: String] = [:]) {
    var additionalInfo = additionalInfo
    additionalInfo["textError"] = message

    // provide your oun mechanism to log errors
}

