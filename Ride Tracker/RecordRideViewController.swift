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

    let motionManager = CMMotionManager()
    let locationManager = CLLocationManager()
    var motionRecorderQueue: OperationQueue = OperationQueue()
    var referenceAttitude: CMAttitude?

    lazy var record: RideRecord = {
        return RideRecord(context: self.context)
    }()

    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

//        recordGyroscope(for: self.record)
//        recordAccelerometer(for: self.record)
//        recordLocation()
    }

    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }

    func recordGyroscope(for ride: RideRecord) {
        motionManager.deviceMotionUpdateInterval = 1.0/100.0
        motionManager.startDeviceMotionUpdates()
        self.referenceAttitude = motionManager.deviceMotion?.attitude

        motionManager.startDeviceMotionUpdates(to: motionRecorderQueue) { (motionData, error) in
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
        motionManager.startAccelerometerUpdates(to: motionRecorderQueue) { (motionData, error) in
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
