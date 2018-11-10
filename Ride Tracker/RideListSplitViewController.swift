//
//  RideListSplitViewController.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 9/27/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit
import CoreData

class RideListSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self

        let leftNavController = self.viewControllers.first as! UINavigationController
        let masterViewController = leftNavController.topViewController as! RideListCollectionViewController
        let detailViewController = self.viewControllers.last as! RideDetailViewController
        let defaults = UserDefaults()

        masterViewController.delegate = detailViewController
        let id = defaults.object(forKey: USER_DEFAULTS_SELECTED_PARK_ID) as? Int

        if id == nil {
            masterViewController.performSegue(withIdentifier: SHOW_PARK_LIST_VIEW, sender: masterViewController)
            return
        }

        let request = NSFetchRequest<Park>(entityName: "Park")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.predicate = NSPredicate(format: "id = %@", argumentArray: [id!])
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let fetch = NSFetchedResultsController<Park>(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)

        try! fetch.performFetch()
        let park = fetch.object(at: IndexPath(row: 0, section: 0))
        masterViewController.parkSelected(park)

        if let currentRideId = defaults.object(forKey: USER_DEFAULTS_CURRENT_WAIT_RIDE_ID) as? Int,
            let currentRide = (park.rides as? Set<Ride>)?.first(where: { (ride) -> Bool in
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
