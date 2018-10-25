//
//  Network.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 10/18/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import Foundation

func getJson(from url:URL, onCompletion handler: @escaping (Any?) -> Void) {
    URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) -> Void in
        if let data = data, let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
            handler(jsonObj)
        }
    }).resume()
}
