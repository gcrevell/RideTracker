//
//  RideListViewController.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 9/27/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit
import CoreLocation

protocol RideSelectionDelegate: class {
    func rideSelected(_ ride: RideOld)
}

protocol ParkSelectionDelegate {
    func parkSelected(_ park: Park)
}

class RideListViewController: UITableViewController {
    
    var park: Park? = nil
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
        return ParkOld.shared.rides.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RIDE_TABLE_VIEW_CELL, for: indexPath) as! RideTableViewCell

        // Configure the cell...
        cell.ride = ParkOld.shared.rides[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.rideSelected(ParkOld.shared.rides[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
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
}

extension RideListViewController: ParkSelectionDelegate {
    func parkSelected(_ park: Park) {
        self.park = park
    }
}
