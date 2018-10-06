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
            headerView.nameLabel.text = ride?.name
        }
    }
    var headerView: RideDetailHeaderView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.headerView = (Bundle.main.loadNibNamed("RideDetailHeaderView", owner: self, options: nil)!.first as! RideDetailHeaderView)
        tableView.tableHeaderView = nil

        tableView.addSubview(headerView)

        tableView.contentInset = UIEdgeInsets(top: TABLE_VIEW_HEADER_HEIGHT, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: TABLE_VIEW_HEADER_HEIGHT)

        updateHeaderView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
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

        headerView.frame = headerRect
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
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
