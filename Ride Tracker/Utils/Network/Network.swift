//
//  Network.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 10/18/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit

func getJson(from url:URL, onCompletion handler: @escaping (Any?) -> Void) {
    URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) -> Void in
        if let data = data, let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
            handler(jsonObj)
        }
    }).resume()
}

func getImage(from url:URL, onCompletion handler: @escaping (UIImage?) -> Void) {
    do {
        let data = try Data(contentsOf: url)
        if let image = UIImage(data: data) {
            handler(image)
        } else {
            handler(nil)
        }
    } catch {
        handler(nil)
    }
}
