//
//  RideType.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 9/27/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit

enum RideType: String {
    case coaster = "Roller coaster"
    case thrill = "Thrill ride"
    case family = "Family ride"
    case kid = "Kid ride"

    func getMapPinColor() -> UIColor {
        switch self {
        case .coaster:
            return UIColor(red: 196.0/255.0, green: 53.0/255.0, blue: 50.0/255.0, alpha: 1)
        case .thrill:
            return UIColor(red: 74.0/255.0, green: 136.0/255.0, blue: 134.0/255.0, alpha: 1)
        case .family:
            return UIColor(red: 65.0/255.0, green: 156.0/255.0, blue: 77.0/255.0, alpha: 1)
        case .kid:
            return UIColor(red: 247.0/255.0, green: 202.0/255.0, blue: 88.0/255.0, alpha: 1)
        }
    }

    func getIcon() -> UIImage? {
        switch self {
        case .coaster:
            return UIImage(named: "Roller Coaster")
        case .thrill:
            return UIImage(named: "Ship Swing")
        case .family:
            return UIImage(named: "Ferris Wheel")
        case .kid:
            return UIImage(named: "Carousel")
        }
    }
}
