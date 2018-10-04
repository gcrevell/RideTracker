//
//  Ride.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 9/27/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit

class Ride {
    var id: Int
    var name: String
    var type: RideType
    var description: String
    var minimumHeight: Int?
    var maximumHeight: Int?
    var photoName: String
    var photo: UIImage
    var closed: Bool
    
    init(
         id: Int,
         name: String,
         type: String,
         description: String,
         minimumHeight: Int?,
         maximumHeight: Int?,
         photoName: String,
         closed: Bool) {
        // Im a little unsure about using these force nil checks, but this data
        // is only fetched from a JSON file included in the project, so it
        // should be fine
        self.id = id
        self.name = name
        self.type = RideType(rawValue: type)!
        self.description = description
        self.minimumHeight = minimumHeight
        self.maximumHeight = maximumHeight
        self.photoName = photoName
        self.closed = closed
        
        self.photo = UIImage(named: "photos/" + self.photoName)!
    }
}
