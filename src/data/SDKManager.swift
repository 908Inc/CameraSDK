//
//  SDKManager.swift
//  iMsgStickerpipe
//
//  Created by vlad on 9/21/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit
import SAMKeychain
import MD5Digest

class SDKManager: NSObject {
    var apiKey: String!
    var userKey: String?
    var downloadMaxImages = false
    let uuid: String

    override init() {
        if let key = UserDefaults.standard.value(forKey: "kUDIDKey") as? String {
            uuid = key
        } else {
            let key = UUID().uuidString
            UserDefaults.standard.setValue(key, forKey: "kUDIDKey")
            uuid = key
        }

        super.init()

        userKey = userId()

        guard let plistPath = Bundle.main.path(forResource: "Stories", ofType: "plist") else {
            fatalError("Can't access Stories.plist; Create it in your root folder")
        }

        guard let plistDict = NSDictionary(contentsOfFile: plistPath), let key = plistDict["StoriesAPIKey"] as? String else {
            fatalError("Can't read your ApiKey from Stories.plist; Add your key for 'StoriesAPIKey' dictionary key")
        }

        apiKey = key
    }

    private func userId() -> String? {
        let kKeychainKey = "4777bba01213e4d82cf3e4d23acfa268"

        if let curPassData = SAMKeychain.passwordData(forService: kKeychainKey, account: "Stickerpipe") {
            return String(data: curPassData, encoding: String.Encoding.utf8)
        } else {
            let currentDeviceId = UIDevice.current.identifierForVendor!.uuidString
            let appVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            let userId = currentDeviceId.appending(appVersionString).md5Digest()

            SAMKeychain.setPassword(userId, forService: kKeychainKey, account: "Stickerpipe")

            return userId
        }
    }
}
