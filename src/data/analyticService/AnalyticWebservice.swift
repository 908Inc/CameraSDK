//
//  AnalyticWebservice.swift
//  Pods
//
//  Created by vlad on 4/6/17.
//
//

import UIKit
import Foundation

class AnalyticWebservice: NSObject {
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    func sendAnalytics(withDicts dicts: [[String: AnyHashable]], responseHandler: ((Error?)->())? = nil) {
        do {
            let data = try JSONSerialization.data(withJSONObject: dicts)

            var request = URLRequest.defaultRequest(forPath: "statistics")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            request.httpMethod = "POST"

            urlSession.dataTask(with: request) { data, response, error in
                do {
                    guard error == nil else {
                        responseHandler?(error)

                        return
                    }
                    guard let data = data else {
                        responseHandler?(error ?? WebservicesError.noData)

                        return
                    }
                    guard let json = try JSONSerialization.jsonObject(with: data) as? NSDictionary else {
                        responseHandler?(error ?? WebservicesError.unknownFormat)

                        return
                    }

                    responseHandler?(nil)
                } catch {
                    responseHandler?(error)
                }
            }.resume()
        } catch {
            responseHandler?(error)
        }
    }


    private let urlSession: URLSession
}
