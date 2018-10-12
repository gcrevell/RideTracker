//
//  EditRideLogViewController.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 10/11/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit

extension TimeInterval {
    var description: String {
        let date = Date(timeIntervalSinceNow: -self)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        let time = formatter.string(from: date, to: Date()) ?? "\(self as Double)"
        return time
    }
}

enum SelectedSection: Int {
    case waitTime = 1
    case riddenDateTime = 2
}

class EditRideLogViewController: UITableViewController, UITextViewDelegate {

    @IBOutlet weak var rideImageView: UIImageView!
    @IBOutlet weak var rideNameLabel: UILabel!
    @IBOutlet weak var waitTimeLabel: UILabel!
    @IBOutlet weak var riddenDateTimeLabel: UILabel!
    @IBOutlet weak var riddenDateTimePicker: UIDatePicker!
    @IBOutlet weak var notesTextView: UITextView!

    var ride: Ride?
    var rideRecord: RideRecord?

    var selectedSection: SelectedSection? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        rideImageView.image = ride?.photo
        rideNameLabel.text = ride?.name
        waitTimeLabel.text = rideRecord?.waitTime.description

        let displayDate = rideRecord?.ridden ?? Date()
        riddenDateTimePicker.date = displayDate
        riddenDateTimePickerUpdated()

        notesTextView.text = rideRecord?.notes

        notesTextView.delegate = self
    }

    @IBAction func riddenDateTimePickerUpdated() {
        let selectedDate = riddenDateTimePicker.date
        riddenDateTimeLabel.text = format(date: selectedDate)
        rideRecord?.ridden = selectedDate
    }

    func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter.string(from: date)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            if selectedSection?.rawValue != indexPath.section {
                return 0
            }
        }

        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 {
            // Header cell
            return nil
        }

        if indexPath.section == 3 {
            // Notes cell
            return nil
        }

        return indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        notesTextView.resignFirstResponder()

        var section = SelectedSection(rawValue: indexPath.section)
        if section == selectedSection {
            section = nil
        }
        selectedSection = section

        tableView.beginUpdates()
        tableView.endUpdates()
    }

    // MARK: - Text view delegate methods

    func textViewDidBeginEditing(_ textView: UITextView) {
        selectedSection = nil
        self.tableView.beginUpdates()
        self.tableView.endUpdates()

        tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .top, animated: true)
    }

    func textViewDidChange(_ textView: UITextView) {
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .top, animated: false)
    }

    // MARK: - Wait time handler methods

    @IBAction func waitTimeSubtract15Min(_ sender: Any) {
        add(timeInterval: -(15 * 60))
    }

    @IBAction func waitTimeSubtract1Min(_ sender: Any) {
        add(timeInterval: -(1 * 60))
    }

    @IBAction func waitTimeSubtract15Sec(_ sender: Any) {
        add(timeInterval: -(15))
    }

    @IBAction func waitTimeAdd15Min(_ sender: Any) {
        add(timeInterval: 15 * 60)
    }

    @IBAction func waitTimeAdd1Min(_ sender: Any) {
        add(timeInterval: 1 * 60)
    }

    @IBAction func waitTimeAdd15Sec(_ sender: Any) {
        add(timeInterval: 15)
    }

    func add(timeInterval: TimeInterval) {
        var wait = rideRecord?.waitTime ?? 0
        wait += timeInterval
        wait = max(wait, 0)
        rideRecord?.waitTime = wait
        waitTimeLabel.text = rideRecord?.waitTime.description
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        save()
    }

    func save() {
        rideRecord?.recorded = Date()
        rideRecord?.notes = notesTextView.text
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        performSegue(withIdentifier: UNWIND_TO_RIDE_DETAIL_VIEW, sender: self)
    }
}
