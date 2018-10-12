//
//  RideDetailViewController.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 10/5/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit
import CoreData

let TABLE_VIEW_HEADER_HEIGHT: CGFloat = 300

let SECTION_TITLES_WITH_HEIGHT_REQUIREMENTS: [(String, [String])] = [("About", ["Description"]),
                                                                     ("New ride", ["Time your wait", "Log a ride"]),
                                                                     ("Height requirements", []),
                                                                     ("Rides", [])]
let SECTION_TITLES_NO_HEIGHT_REQUIREMENTS: [(String, [String])] = [("About", ["Description"]),
                                                                   ("New ride", ["Time your wait", "Log a ride"]),
                                                                   ("Rides", [])]

class RideDetailViewController: UITableViewController {

    var fetch: NSFetchedResultsController<RideRecord>? = nil
    var sectionTitles = SECTION_TITLES_WITH_HEIGHT_REQUIREMENTS
    var ride: Ride? = nil {
        didSet {
            if ride?.minimumHeight != nil || ride?.maximumHeight != nil {
                sectionTitles = SECTION_TITLES_WITH_HEIGHT_REQUIREMENTS
                // Reset height requirement array
                sectionTitles[2].1 = []
                if ride?.minimumHeight != nil {
                    sectionTitles[2].1.append("Minimum height of \(ride!.minimumHeight!)“")
                }
                if ride?.maximumHeight != nil {
                    sectionTitles[2].1.append("Maximum height of \(ride!.maximumHeight!)“")
                }
            } else {
                sectionTitles = SECTION_TITLES_NO_HEIGHT_REQUIREMENTS
            }

            sectionTitles[0].1 = [ride?.description ?? "Description"]

            headerView.imageView.image = ride?.photo
            headerView.nameLabel.text = ride?.name ?? " "
            headerView.rideTypeLabel.text = ride?.type.rawValue ?? " "

            headerView.colors = nil
            ride?.photo.getColors({ (colors) in
                self.headerView.colors = colors
                self.updateHeaderView()
            })

            updateHeaderView()
            updateFetch()

            tableView.reloadData()
        }
    }
    var headerView: RideDetailHeaderView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.headerView = (Bundle.main.loadNibNamed("RideDetailHeaderView", owner: self, options: nil)!.first as! RideDetailHeaderView)
        headerView.layer.zPosition = 2
        tableView.tableHeaderView = nil

        tableView.addSubview(headerView)

        tableView.contentInset = UIEdgeInsets(top: TABLE_VIEW_HEADER_HEIGHT, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: TABLE_VIEW_HEADER_HEIGHT)

        headerView.viewDidLoad()

        updateHeaderView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateFetch()
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
        updateHeaderView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            self.ride = nil
        }
    }

    func updateFetch(reload: Bool = true) {
        guard let ride = self.ride else {
            self.fetch = nil
            return
        }

        let request = NSFetchRequest<RideRecord>(entityName: "RideRecord")
        request.sortDescriptors = [NSSortDescriptor(key: "ridden", ascending: false)]
        let id = ride.id
        request.predicate = NSPredicate(format: "rideId == %@", "\(id)")
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let fetch = NSFetchedResultsController<RideRecord>(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)

        try! fetch.performFetch()
        self.fetch = fetch

        if reload {
            tableView.reloadData()
        }
    }

    func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -TABLE_VIEW_HEADER_HEIGHT, width: tableView.bounds.width, height: TABLE_VIEW_HEADER_HEIGHT)
        // If scrolling past the defined height, stretch the header
        if tableView.contentOffset.y < -TABLE_VIEW_HEADER_HEIGHT {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }

        // Adjust the origin y value to keep the name label on screen
        let heightNeededForLabel = headerView.labelContainer.frame.height + self.view.safeAreaInsets.top
        if tableView.contentOffset.y > -heightNeededForLabel {
            headerRect.origin.y = -(TABLE_VIEW_HEADER_HEIGHT - (tableView.contentOffset.y + heightNeededForLabel))
        }

        let progress = { () -> CGFloat in
            let currentScrollPosition = (-self.tableView.contentOffset.y) - heightNeededForLabel
            let maxScrollPosition = TABLE_VIEW_HEADER_HEIGHT - heightNeededForLabel
            let rawProgress = currentScrollPosition / maxScrollPosition
            return 1 - min(max(rawProgress, 0), 1)
        }()

        let alpha = tableView.contentOffset.y > -TABLE_VIEW_HEADER_HEIGHT ? progress * 0.25 + 0.75 : 0.75
        let gradientAlpha = tableView.contentOffset.y > -TABLE_VIEW_HEADER_HEIGHT ? progress : 0.0
        let color = headerView.colors?.background ?? UIColor(white: 0.25, alpha: 1.0)
        let colors = [color.withAlphaComponent(gradientAlpha).cgColor, color.withAlphaComponent(alpha).cgColor]

        headerView.layoutTitleContainerGradient(colors: colors)
        headerView.nameLabel.textColor = headerView.colors?.primary ?? .white
        headerView.rideTypeLabel.textColor = headerView.colors?.secondary ?? .white

        headerView.frame = headerRect
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section].0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == sectionTitles.count - 1 {
            // Rides list, which we won't store in the array
            let count = fetch?.sections?[0].numberOfObjects ?? 0
            return count == 0 ? 1 : count
        }
        return sectionTitles[section].1.count
    }

    var descriptionNumberOfLines = 4

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section != sectionTitles.count - 1 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = sectionTitles[indexPath.section].1[indexPath.row]
            cell.textLabel?.numberOfLines = descriptionNumberOfLines
            return cell
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.doesRelativeDateFormatting = true

        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

        if let fetch = self.fetch {
            if fetch.sections?[0].numberOfObjects != 0 {
                cell.textLabel?.text = formatter.string(from: fetch.object(at: IndexPath(row: indexPath.row, section: 0)).ridden!)
            } else {
                cell.textLabel?.text = "You haven't ridden this yet"
            }
        } else {
            cell.textLabel?.text = "Couldn't load your rides!"
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 2 && sectionTitles.count == 4 {
            return false
        }

        return true
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: false)
            descriptionNumberOfLines = descriptionNumberOfLines == 0 ? 4 : 0
            tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }

        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 1 {
            // New ride section
            if indexPath.row == 0 {
                // Record wait time
                self.performSegue(withIdentifier: SHOW_RIDE_WAIT_TIME_COUNTER, sender: self)
                return
            }
            if indexPath.row == 1 {
                self.performSegue(withIdentifier: SHOW_EDIT_RIDE_LOG, sender: self)
                return
            }
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let rideRecord = fetch?.object(at: IndexPath(row: indexPath.row, section: 0)) {
                let delegate = UIApplication.shared.delegate as? AppDelegate
                delegate?.persistentContainer.viewContext.delete(rideRecord)
                delegate?.saveContext()
                updateFetch(reload: false)

                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .left)
                if indexPath.row == 0 {
                    tableView.insertRows(at: [indexPath], with: .right)
                }
                tableView.endUpdates()
            }
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == SHOW_EDIT_RIDE_LOG {
            return self.ride != nil
        }

        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SHOW_RIDE_WAIT_TIME_COUNTER,
            let dest = segue.destination as? RideWaitTimeCounterViewController {
            dest.ride = self.ride

            return
        }

        if segue.identifier == SHOW_EDIT_RIDE_LOG,
            let dest = segue.destination as? EditRideLogViewController {
            guard let ride = self.ride else { return }
            dest.ride = self.ride

            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let record = RideRecord(context: context)

            record.ridden = Date()
            record.recorded = Date()
            record.waitTime = 0
            record.rideId = Int64(ride.id)

            dest.rideRecord = record

            return
        }
    }

    @IBAction func unwindToRideDetailView(segue:UIStoryboardSegue) { }
}

extension RideDetailViewController: RideSelectionDelegate {
    func rideSelected(_ ride: Ride) {
        self.ride = ride
    }
}
