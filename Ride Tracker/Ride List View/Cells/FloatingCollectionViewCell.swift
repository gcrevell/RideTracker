//
//  FloatingCollectionViewCell.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 11/9/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit

class FloatingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var outerContainerView: UIView!
    @IBOutlet weak var shadowView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        outerContainerView.layer.cornerRadius = 6
        outerContainerView.clipsToBounds = true
        shadowView.layer.cornerRadius = 6
        shadowView.clipsToBounds = false

        shadowView.layer.shadowColor = UIColor.shadow.cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowRadius = 4
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)

        self.clipsToBounds = false
    }
    
}
