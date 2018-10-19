//
//  RideListSplitViewController.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 9/27/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit

class RideListSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self

        let leftNavController = self.viewControllers.first as! UINavigationController
        let masterViewController = leftNavController.topViewController as! RideListViewController
        let detailViewController = self.viewControllers.last as! RideDetailViewController
        let defaults = UserDefaults()

        masterViewController.delegate = detailViewController

        if defaults.object(forKey: USER_DEFAULTS_SELECTED_PARK_ID) == nil {
            masterViewController.performSegue(withIdentifier: SHOW_PARK_LIST_VIEW, sender: masterViewController)
            return
        }

        if let currentRideId = defaults.object(forKey: USER_DEFAULTS_CURRENT_WAIT_RIDE_ID) as? Int,
            let currentRide = ParkOld.shared.rides.first(where: { (ride) -> Bool in
                return ride.id == currentRideId
            }) {
            detailViewController.ride = currentRide

            return
        }
    }

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if let detailController = secondaryViewController as? RideDetailViewController {
            if detailController.ride == nil {
                return true
            }
        }
        return false
    }
}
