//
//  RideCollectionViewCell.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 11/3/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit

class RideCollectionViewCell: FloatingCollectionViewCell {

    @IBOutlet weak var rideNameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    var shouldUpdateImage: RefBool?
    var ride: Ride? {
        didSet {
            guard let ride = ride else { return }

            self.imageView.image = nil
            shouldUpdateImage?.val = false
            let shouldUpdate = RefBool(true)
            shouldUpdateImage = shouldUpdate
            ride.set(imageView: self.imageView, shouldUpdateImage: shouldUpdate)
            
            rideNameLabel.text = ride.name ?? ""
        }
    }
}
