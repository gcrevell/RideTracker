//
//  RidesTableViewCell.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 9/27/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit

final class RefBool { var val: Bool; init(_ boolean: Bool) { val = boolean } }

class RideTableViewCell: UITableViewCell {

    var shouldUpdateImage: RefBool?
    var ride: Ride? {
        didSet {
            guard let ride = ride else { return }
            self.icon.image = nil
            shouldUpdateImage?.val = false
            let shouldUpdate = RefBool(true)
            shouldUpdateImage = shouldUpdate
            ride.set(imageView: self.icon, shouldUpdateImage: shouldUpdate)
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
