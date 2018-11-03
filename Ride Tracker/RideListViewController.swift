//
//  RideListViewController.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 9/27/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

protocol RideSelectionDelegate: class {
    func rideSelected(_ ride: Ride)
}

protocol ParkSelectionDelegate {
    func parkSelected(_ park: Park)
}

class RideListViewController: UITableViewController {

    var fetch: NSFetchedResultsController<Ride>? = nil
    var park: Park? = nil {
        didSet {
            print("test")
            self.loadRides()
        }
    }
    weak var delegate: RideSelectionDelegate?
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = park?.name

        self.locationManager.requestAlwaysAuthorization()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetch?.fetchedObjects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RIDE_TABLE_VIEW_CELL, for: indexPath) as! RideTableViewCell

        // Configure the cell...
        cell.ride = fetch?.fetchedObjects?[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let selectedRide = fetch?.fetchedObjects?[indexPath.row] else { return }
        delegate?.rideSelected(selectedRide)
        if let detailViewController = delegate as? RideDetailViewController {
            splitViewController?.showDetailViewController(detailViewController, sender: nil)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96.0
    }

    @IBAction func unwindToRideListView(segue:UIStoryboardSegue) { }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SHOW_PARK_LIST_VIEW,
            let dest = segue.destination as? ParkTableViewController {
            dest.delegate = self
        }
    }

    func loadRides() {
        self.park?.loadRides {
            DispatchQueue.main.async {
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                self.updateFetch()
            }
        }
    }

    func updateFetch(reload: Bool = true) {
        guard let park = self.park else {
            self.fetch = nil
            return
        }

        let request = NSFetchRequest<Ride>(entityName: "Ride")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let id = park.id
        request.predicate = NSPredicate(format: "park.id == %@", "\(id)")
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let fetch = NSFetchedResultsController<Ride>(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)

        try! fetch.performFetch()
        self.fetch = fetch

        if reload {
            tableView.reloadData()
        }
    }
}

extension RideListViewController: ParkSelectionDelegate {
    func parkSelected(_ park: Park) {
        self.park = park
    }
}
