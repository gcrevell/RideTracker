//
//  RidesTableViewCell.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 9/27/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit

class RideTableViewCell: UITableViewCell {

    var ride: Ride! {
        didSet {
            self.icon.image = ride.photo
            self.icon.clipsToBounds = true

            self.rideNameLabel.text = ride.name
        }
    }

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var rideNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
