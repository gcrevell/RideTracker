//
//  RideDetailViewController.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 9/27/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit

class RideWaitTimeCounterViewController: UIViewController {

    var timer: Timer?
    var ride: RideOld? = nil {
        didSet {
            timer?.invalidate()
            timer = nil
            let defaults = UserDefaults()

            if let ride = ride {
                if defaults.object(forKey: USER_DEFAULTS_CURRENT_WAIT_RIDE_ID) as? Int != ride.id {
                    defaults.set(ride.id, forKey: USER_DEFAULTS_CURRENT_WAIT_RIDE_ID)
                    defaults.set(Date(), forKey: USER_DEFAULTS_CURRENT_WAIT_START_TIME)

                    defaults.synchronize()
                }

                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
                    self.timerLabel.text = self.time()
                }

                self.navigationItem.title = ride.name
            } else {
                defaults.removeObject(forKey: USER_DEFAULTS_CURRENT_WAIT_RIDE_ID)
                defaults.removeObject(forKey: USER_DEFAULTS_CURRENT_WAIT_START_TIME)
                timer?.invalidate()
                timer = nil
                defaults.synchronize()
                self.timerLabel.text = time()
            }
        }
    }

    @IBOutlet weak var timerLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.timerLabel.minimumScaleFactor = 40.0/self.timerLabel.font.pointSize
        self.timerLabel.text = time()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            self.ride = nil
        }
    }

    @IBAction func recordRidePressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: SHOW_RIDE_RECORDING, sender: self)
    }

    @IBAction func logRidePressed(_ sender: Any) {
        self.performSegue(withIdentifier: SHOW_EDIT_RIDE_LOG, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        timer?.invalidate()

        let defaults = UserDefaults()
        let startdate = defaults.object(forKey: USER_DEFAULTS_CURRENT_WAIT_START_TIME) as? Date ?? Date()
        let elapsedTime = Date().timeIntervalSince(startdate)

        if let dest = segue.destination as? RecordRideViewController {
            dest.waittime = elapsedTime
            dest.ride = self.ride
            self.ride = nil
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
            record.waitTime = elapsedTime
            record.rideId = Int64(ride.id)

            dest.rideRecord = record
        }

        defaults.removeObject(forKey: USER_DEFAULTS_CURRENT_WAIT_RIDE_ID)
        defaults.removeObject(forKey: USER_DEFAULTS_CURRENT_WAIT_RIDE_NAME)
        defaults.removeObject(forKey: USER_DEFAULTS_CURRENT_WAIT_START_TIME)
    }

    func time() -> String {
        let defaults = UserDefaults()
        let defaultTime = "0:00"

        if let date = defaults.object(forKey: USER_DEFAULTS_CURRENT_WAIT_START_TIME) as? Date {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad
            let time = formatter.string(from: date, to: Date())
            return time ?? defaultTime
        }

        return defaultTime
    }
}
