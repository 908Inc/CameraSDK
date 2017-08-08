//
//  AnalyticWebservice.swift
//  Pods
//
//  Created by vlad on 4/6/17.
//
//

import UIKit
import Foundation

class AnalyticWebservice: Webservice {
    func sendAnalytics(withDicts dicts: [[String: AnyHashable]], responseHandler: (([String: AnyHashable]?, Error?)->())? = nil) {
        do {
            let data = try JSONSerialization.data(withJSONObject: dicts)

            var request = URLRequest.defaultRequest(forPath: "statistics")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            request.httpMethod = "POST"

            urlSession.dataTask(with: request) { data, response, error in
                self.parseResponse(data, error: error, completion: responseHandler)
            }.resume()
        } catch {
            responseHandler?(nil, error)
        }
    }
}
