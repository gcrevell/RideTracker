//
//  Rides.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 9/27/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import Foundation

class ParkOld {
    static let shared = ParkOld(for: UserDefaults().string(forKey: USER_DEFAULTS_SELECTED_PARK) ?? "Cedar Point")
    
    private(set) var rides: [RideOld] = []
    
    private init(for park: String) {
        self.load(park)
    }
    
    /// Load the ride data for a specific park from the JSON file
    ///
    /// This is a very unsafe method, with many force unwraps. This is considered
    /// "safe" at least for my needs because it is only loading static JSON files
    /// and not dynamic content.
    ///
    /// - Parameter name: The name of the park to load rides for
    func load(_ parkName: String) {
        let file = Bundle.main.url(forResource: "Cedar-Point-rides", withExtension: "json")!
        let data = (try? Data(contentsOf: file))!
        let json = (try? JSONSerialization.jsonObject(with: data) as! [String : Any])!
        
        self.rides = []
        
        let park = json[parkName] as! [String : Any]
        let rides = park["rides"] as! [[String : Any]]
        
        for ride in rides {
            self.rides.append(RideOld(
                                   id: ride["id"] as! Int,
                                   name: ride["name"] as! String,
                                   type: ride["type"] as! String,
                                   description: ride["description"] as! String,
                                   minimumHeight: ride["minimumHeight"] as? Int,
                                   maximumHeight: ride["maximumHeight"] as? Int,
                                   photoName: ride["photoName"] as! String,
                                   closed: ride["closed"] as! Bool))
        }

        self.rides.sort { (a, b) -> Bool in
            return a.name < b.name
        }
    }
}
