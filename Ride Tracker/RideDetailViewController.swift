//
//  RideDetailViewController.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 10/5/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit

class RideDetailViewController: UITableViewController {

    var ride: Ride? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RideDetailViewController: RideSelectionDelegate {
    func rideSelected(_ ride: Ride) {
        self.ride = ride
    }
}
