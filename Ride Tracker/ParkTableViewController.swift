//
//  ParkTableViewController.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 10/18/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit
import CoreData

class ParkTableViewController: UITableViewController {

    var fetch: NSFetchedResultsController<Park>?
    var delegate: ParkSelectionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        loadParkClasses()

        updateFetch()

        self.navigationItem.hidesBackButton = true
    }

    func updateFetch(reload: Bool = true) {
        let request = NSFetchRequest<Park>(entityName: "Park")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let fetch = NSFetchedResultsController<Park>(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)

        try! fetch.performFetch()
        self.fetch = fetch

        if reload {
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetch?.sections?[0].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let park = fetch?.object(at: indexPath)
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

        cell.textLabel?.text = park?.name

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let park = fetch!.object(at: indexPath)
        let defaults = UserDefaults()
        defaults.set(park.id, forKey: USER_DEFAULTS_SELECTED_PARK_ID)
        defaults.synchronize()

        delegate?.parkSelected(park)

        self.performSegue(withIdentifier: UNWIND_TO_RIDE_LIST_VIEW, sender: self)
    }
}
