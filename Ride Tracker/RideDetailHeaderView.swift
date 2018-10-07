//
//  RideDetailHeaderView.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 10/6/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit

class RideDetailHeaderView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelContainer: UIView!
    @IBOutlet weak var nameLabel: UILabel!

    let gradient = CAGradientLayer()

    func viewDidLoad() {
        self.labelContainer.layer.insertSublayer(gradient, at: 0)

        self.labelContainer.backgroundColor = nil
    }

    func layoutTitleContainerGradient(colors: [CGColor]) {
        let width = self.frame.width
        gradient.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: labelContainer.frame.height))
        gradient.startPoint = CGPoint(x: 8/width, y: 0.5)
        gradient.endPoint = CGPoint(x: 40/width, y: 0.5)
        gradient.colors = colors
    }
}
