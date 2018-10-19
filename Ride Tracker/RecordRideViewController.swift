//
//  RecordRideViewController.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 9/27/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit
import CoreMotion
import CoreData
import CoreLocation

class RecordRideViewController: UIViewController, CLLocationManagerDelegate {

    var waittime: TimeInterval = 0
    var ride: RideOld?

    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var finishRecordingButton: UIButton!

    let motionManager = CMMotionManager()
    let locationManager = CLLocationManager()
    var motionRecorderQueue: OperationQueue = OperationQueue()
    var referenceAttitude: CMAttitude?
    var countdownTimer: Timer?

    lazy var record: RideRecord = {
        return RideRecord(context: self.context)
    }()

    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.record.waitTime = self.waittime
        self.record.recorded = Date()
        self.record.ridden = Date()
//        self.record.rideId = Int64(self.ride!.id)

        var countdownTime = 5

        countdownLabel.text = "\(countdownTime)"

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            countdownTime -= 1

            self.countdownLabel.text = "\(countdownTime)"

            if countdownTime <= 0 {
                self.countdownTimer?.invalidate()

                self.countdownLabel.text = "Go!"

                self.recordGyroscope(for: self.record)
                self.recordAccelerometer(for: self.record)
                self.recordLocation()
            }
        }

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelRecord))
    }

    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopAccelerometerUpdates()
        locationManager.stopUpdatingLocation()
    }

    func recordGyroscope(for ride: RideRecord) {
        motionManager.deviceMotionUpdateInterval = 1.0/100.0
        motionManager.startDeviceMotionUpdates()
        self.referenceAttitude = motionManager.deviceMotion?.attitude

        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (motionData, error) in
            guard motionData != nil else { return }

            if self.referenceAttitude == nil {
                self.referenceAttitude = motionData!.attitude.copy(with: nil) as? CMAttitude
            }

            if let referenceAttitude = self.referenceAttitude,
                let currentAttitude = motionData?.attitude {
                currentAttitude.multiply(byInverseOf: referenceAttitude)
                let gyroscope = GyroscopeData(context: self.context)
                gyroscope.ride = self.record
                gyroscope.timestamp = motionData!.timestamp

                gyroscope.roll = currentAttitude.roll
                gyroscope.pitch = currentAttitude.pitch
                gyroscope.yaw = currentAttitude.yaw
            }
        }
    }

    func recordAccelerometer(for ride: RideRecord) {
        motionManager.accelerometerUpdateInterval = 1.0/100.0
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (motionData, error) in
            guard motionData != nil else { return }

            let acceleration = AccelerometerData(context: self.context)
            acceleration.ride = ride
            acceleration.timestamp = motionData!.timestamp

            acceleration.x = motionData!.acceleration.x
            acceleration.y = motionData!.acceleration.y
            acceleration.z = motionData!.acceleration.z
        }
    }

    func recordLocation() {
        guard CLLocationManager.locationServicesEnabled() else { return }

        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            if location.speed < 0 {
                return
            }

            let locationDataPoint = LocationData(context: self.context)
            locationDataPoint.ride = self.record
            locationDataPoint.timestamp = location.timestamp
            locationDataPoint.altitude = location.altitude
            locationDataPoint.latitude = location.coordinate.latitude
            locationDataPoint.longitude = location.coordinate.longitude
            locationDataPoint.speed = location.speed
        }
    }

    @objc func cancelRecord() {
        countdownTimer?.invalidate()
        stopUpdates()
        self.motionRecorderQueue.cancelAllOperations()
        self.context.delete(self.record)
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()

        performSegue(withIdentifier: UNWIND_TO_RIDE_DETAIL_VIEW, sender: self)
    }

    @IBAction func finishRecording(_ sender: Any) {
        countdownTimer?.invalidate()
        stopUpdates()
        self.motionRecorderQueue.waitUntilAllOperationsAreFinished()
        performSegue(withIdentifier: SHOW_EDIT_RIDE_LOG, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SHOW_EDIT_RIDE_LOG,
            let dest = segue.destination as? EditRideLogViewController {
            dest.ride = self.ride
            dest.rideRecord = self.record
        }
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
