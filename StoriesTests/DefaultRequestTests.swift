//
//  DefaultRequestTests.swift
//  Stories
//
//  Created by vlad on 3/29/17.
//  Copyright © 2017 908. All rights reserved.
//

import XCTest
@testable import Stamps

class DefaultRequestTests: XCTestCase {
    func testDefaultRequest() {
        let testPath = "testUrl"

        let defaultRequest = URLRequest.defaultRequest(forPath: testPath)

        let userId = defaultRequest.value(forHTTPHeaderField: "UserID")
        if userId == nil || userId!.isEmpty {
            XCTFail()
        }
        let deviceId = defaultRequest.value(forHTTPHeaderField: "DeviceId")
        if deviceId == nil, deviceId!.isEmpty {
            XCTFail()
        }
        let apiKey = defaultRequest.value(forHTTPHeaderField: "ApiKey")
        if apiKey == nil, apiKey!.isEmpty {
            XCTFail()
        }
        let platform = defaultRequest.value(forHTTPHeaderField: "Platform")
        if platform == nil, platform!.isEmpty {
            XCTFail()
        }
        let appVersion = defaultRequest.value(forHTTPHeaderField: "AppVersion")
        if appVersion == nil, appVersion!.isEmpty {
            XCTFail()
        }
        let package = defaultRequest.value(forHTTPHeaderField: "Package")
        if package == nil, package!.isEmpty {
            XCTFail()
        }
        let localization = defaultRequest.value(forHTTPHeaderField: "Localization")
        if localization == nil, localization!.isEmpty {
            XCTFail()
        }
        let density = defaultRequest.value(forHTTPHeaderField: "Density")
        if density == nil, density!.isEmpty {
            XCTFail()
        }

        let work = false
        let apiVersion = "v2"
        let rootUrlString = work ? "http://work.stk.908.vc" : "https://api.stickerpipe.com"

        XCTAssertEqual(defaultRequest.url, URL(string: "\(rootUrlString)/api/\(apiVersion)/testUrl"))
    }
}
