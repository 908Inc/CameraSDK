//
//  SessionManager.swift
//  iMsgStickerpipe
//
//  Created by vlad on 9/21/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit
import SDWebImage

public class SessionManager: NSObject {
    public static let shared = SessionManager()
    public var analyticService: AnalyticService!
    
    let sdkManager = SDKManager()
    let coreDataManager = CoreDataManager()

    override init() {
        super.init()

        SDImageCache.shared().config.shouldCacheImagesInMemory = false

        // move here, because it uses coreDataManager during default init
        #if DEBUG
        analyticService = DebugAnalyticService(moc: coreDataManager.mainContext)
        #else
        analyticService = AnalyticService(moc: coreDataManager.mainContext)
        #endif

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }

    func applicationDidEnterBackground(_ notification: NSNotification) {
        analyticService.sendAnalytics()
    }
}
