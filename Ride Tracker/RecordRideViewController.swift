//
//  RecordRideViewController.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 9/27/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit
import CoreMotion

class RecordRideViewController: UIViewController {

    var waittime: TimeInterval = 0

    let motionManager = CMMotionManager()
    var motionRecorderQueue: OperationQueue = OperationQueue()

    @IBOutlet weak var accelerometerChart: MotionChartView!
    var accelerometerData: [CMAccelerometerData] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        motionManager.accelerometerUpdateInterval = 1.0 / 100.0
        motionManager.startAccelerometerUpdates(to: self.motionRecorderQueue) { (data, error) in
            if let data = data {
                self.accelerometerData.append(data)
                DispatchQueue.main.async {
                    self.accelerometerChart.setAccelerometerData(self.accelerometerData)
                }
            }
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
