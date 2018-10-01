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

        masterViewController.delegate = detailViewController
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
