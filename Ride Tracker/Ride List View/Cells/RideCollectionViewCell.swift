//
//  RideCollectionViewCell.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 11/3/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit

class RideCollectionViewCell: FloatingCollectionViewCell {

//    @IBOutlet weak var shadowView: UIView!
//    @IBOutlet weak var outerContainerView: UIView!
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

//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//        outerContainerView.layer.cornerRadius = 6
//        shadowView.layer.cornerRadius = 6
//
//        shadowView.layer.shadowColor = UIColor.shadow.cgColor
//        shadowView.layer.shadowOpacity = 1
//        shadowView.layer.shadowRadius = 4
//        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
//
//        self.clipsToBounds = false
//    }
}
