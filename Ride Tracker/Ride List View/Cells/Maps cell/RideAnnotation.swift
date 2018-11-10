//
//  RideAnnotation.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 11/9/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit
import MapKit

class RideAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    let ride: Ride

    init(with ride: Ride) {
        self.ride = ride
        let coord = CLLocationCoordinate2D(latitude: ride.latitude, longitude: ride.longitude)
        self.coordinate = coord

        super.init()
    }

    var title: String? {
        return ride.name
    }
}
