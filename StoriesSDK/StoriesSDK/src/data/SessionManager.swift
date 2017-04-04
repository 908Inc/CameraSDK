//
//  SessionManager.swift
//  iMsgStickerpipe
//
//  Created by vlad on 9/21/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit
import SDWebImage

class SessionManager: NSObject {
    static let shared = SessionManager()
    let sdkManager = SDKManager()
    let coreDataManager = CoreDataManager()

    override init() {
        super.init()

        SDImageCache.shared().config.shouldCacheImagesInMemory = false
    }
}
