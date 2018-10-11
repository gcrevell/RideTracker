//
//  RideDetailViewController.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 10/5/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit

let TABLE_VIEW_HEADER_HEIGHT: CGFloat = 300

let SECTION_TITLES_WITH_HEIGHT_REQUIREMENTS: [(String, [String])] = [("About", ["Description"]),
                                                                     ("New ride", ["Time wait", "Log ride"]),
                                                                     ("Height requirements", []),
                                                                     ("Rides", [])]
let SECTION_TITLES_NO_HEIGHT_REQUIREMENTS: [(String, [String])] = [("About", ["Description"]),
                                                                   ("New ride", ["Time wait", "Log ride"]),
                                                                   ("Rides", [])]

class RideDetailViewController: UITableViewController {

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

        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
        updateHeaderView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            self.ride = nil
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
            return 50
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

        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "\(indexPath.row)"
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
    }
}

extension RideDetailViewController: RideSelectionDelegate {
    func rideSelected(_ ride: Ride) {
        self.ride = ride
    }
}
