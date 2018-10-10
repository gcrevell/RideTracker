//
//  RideDetailViewController.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 10/5/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit

let TABLE_VIEW_HEADER_HEIGHT: CGFloat = 300

class RideDetailViewController: UITableViewController {

    var ride: Ride? = nil {
        didSet {
            headerView.imageView.image = ride?.photo
            headerView.nameLabel.text = ride?.name ?? " "

            headerView.colors = nil
            ride?.photo.getColors({ (colors) in
                self.headerView.colors = colors
                self.updateHeaderView()
            })

            updateHeaderView()
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

        headerView.frame = headerRect
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else if section == 1 {
            return "New ride"
        } else if section == 2 {
            return "Rides"
        }

        return nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if section == 1 {
            return 2
        }
        return 50
    }

    var descriptionNumberOfLines = 4

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = self.ride?.description
            cell.textLabel?.numberOfLines = descriptionNumberOfLines
            return cell
        }

        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.textLabel?.text = "Record ride"
                return cell
            }
            if indexPath.row == 1 {
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.textLabel?.text = "Log ride"
                return cell
            }
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: false)
            descriptionNumberOfLines = descriptionNumberOfLines == 0 ? 4 : 0
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

extension RideDetailViewController: RideSelectionDelegate {
    func rideSelected(_ ride: Ride) {
        self.ride = ride
    }
}