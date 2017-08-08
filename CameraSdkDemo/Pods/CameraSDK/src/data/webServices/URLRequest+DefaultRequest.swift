//
//  URLRequest+DefaultRequest.swift
//  Stories
//
//  Created by vlad on 3/29/17.
//  Copyright © 2017 908. All rights reserved.
//

import Foundation

fileprivate let platform = "iOS"
fileprivate let work = false

fileprivate let baseUrl: URL = {
    let apiVersion = "v2"
    let rootUrlString = work ? "http://work.stk.908.vc" : "https://api.stickerpipe.com"

    return URL(string: "\(rootUrlString)/api/\(apiVersion)")!
}()

fileprivate let appVersionString: String = {
    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String

    return appVersion + build
}()

public extension URLRequest {
    public static func defaultRequest(forPath pathComponent: String) -> URLRequest {
        let url = baseUrl.appendingPathComponent(pathComponent)

        var request = URLRequest(url: url)
        request.setValue(SessionManager.shared.sdkManager.userKey, forHTTPHeaderField: "UserID")
        request.setValue(SessionManager.shared.sdkManager.uuid, forHTTPHeaderField: "DeviceId")
        request.setValue(SessionManager.shared.sdkManager.apiKey, forHTTPHeaderField: "ApiKey")
        request.setValue(platform, forHTTPHeaderField: "Platform")
        request.setValue(appVersionString, forHTTPHeaderField: "AppVersion")
        request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "Package")
        request.setValue(Locale.preferredLanguages.first, forHTTPHeaderField: "Localization")
        request.setValue(Utility.scaleString, forHTTPHeaderField: "Density")
//        if work {
            request.setValue("1", forHTTPHeaderField: "X-BYPASS-CACHE")
//        }

        return request
    }
}
