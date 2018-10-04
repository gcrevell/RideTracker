//
//  RideDetailViewController.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 9/27/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit

class RideDetailViewController: UIViewController {

    var timer: Timer?
    var ride: Ride? = nil {
        didSet {
            timer?.invalidate()
            timer = nil
            let defaults = UserDefaults()

            if let ride = ride, defaults.string(forKey: USER_DEFAULTS_CURRENT_WAIT_RIDE_NAME) != ride.name {
                defaults.set(ride.name, forKey: USER_DEFAULTS_CURRENT_WAIT_RIDE_NAME)
                defaults.set(Date(), forKey: USER_DEFAULTS_CURRENT_WAIT_START_TIME)

                defaults.synchronize()

                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
                    if let date = defaults.object(forKey: USER_DEFAULTS_CURRENT_WAIT_START_TIME) as? Date {
                        let formatter = DateComponentsFormatter()
                        formatter.allowedUnits = [.minute, .second]
                        formatter.unitsStyle = .positional
                        formatter.zeroFormattingBehavior = .pad
                        let time = formatter.string(from: date, to: Date())
                        self.timerLabel.text = time
                    }
                }
            } else if ride == nil {
                defaults.removeObject(forKey: USER_DEFAULTS_CURRENT_WAIT_RIDE_NAME)
                defaults.removeObject(forKey: USER_DEFAULTS_CURRENT_WAIT_START_TIME)
                timer?.invalidate()
                timer = nil
                defaults.synchronize()
                self.timerLabel.text = "0:00"
            }
        }
    }

    @IBOutlet weak var timerLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.timerLabel.minimumScaleFactor = 40.0/self.timerLabel.font.pointSize
        self.timerLabel.text = "0:00"
    }

    @IBAction func recordRidePressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: SHOW_RIDE_RECORDING, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        timer?.invalidate()
        if let dest = segue.destination as? RecordRideViewController {
            let startdate = UserDefaults().object(forKey: USER_DEFAULTS_CURRENT_WAIT_START_TIME) as? Date ?? Date()
            dest.waittime = Date().timeIntervalSince(startdate)
        }
    }
}

extension RideDetailViewController: RideSelectionDelegate {
    func rideSelected(_ ride: Ride) {
        self.ride = ride
    }
}
