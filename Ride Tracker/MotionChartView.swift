//
//  MotionChartView.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 9/28/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit
import CoreMotion

struct MotionData {
    var timestamp: TimeInterval
    var x: Double
    var y: Double
    var z: Double
    var a: Double
}

typealias ChartPoint = (TimeInterval, Double)

class MotionChartView: UIView {

    fileprivate var motionDataPoints: [MotionData] = []
    var displayDataPoints = 500

    func setAccelerometerData(_ data:[CMAccelerometerData]) {
        var motionData:[MotionData] = []

        for point in data {
            let magnitude = sqrt(pow(point.acceleration.x, 2) + pow(point.acceleration.y, 2) + pow(point.acceleration.z, 2))

            motionData.append(MotionData(timestamp: point.timestamp,
                                         x: point.acceleration.x,
                                         y: point.acceleration.y,
                                         z: point.acceleration.z,
                                         a: magnitude))
        }

        motionData = motionData.sorted(by: { (a, b) -> Bool in
            return a.timestamp < b.timestamp
        })

        self.motionDataPoints = motionData
//        self.updateChart()
    }

//    func transformData() -> (x: [ChartPoint], y: [ChartPoint], z: [ChartPoint], a: [ChartPoint]) {
//        var x: [ChartPoint] = []
//        var y: [ChartPoint] = []
//        var z: [ChartPoint] = []
//        var a: [ChartPoint] = []
//
//        let dataPoints = motionDataPoints[0..<min(displayDataPoints, motionDataPoints.count)]
//
//        for dataPoint in dataPoints {
//            x.append((dataPoint.x, dataPoint.timestamp))
//            y.append((dataPoint.y, dataPoint.timestamp))
//            z.append((dataPoint.z, dataPoint.timestamp))
//            a.append((dataPoint.a, dataPoint.timestamp))
//        }
//
//        return (x, y, z, a)
//    }
//
//    func getChartConfig() -> ChartConfigXY {
//        // We're going to assume that the motion data points were already sorted
//        let dataPoints = motionDataPoints[0..<min(displayDataPoints, motionDataPoints.count)]
//        var maxY = 0.0
//        var minY = 0.0
//        var maxT = 0.0
//        var minT = 0.0
//
//        for dataPoint in dataPoints {
//            maxY = max(dataPoint.a, maxY)
//            maxT = max(dataPoint.timestamp, maxT)
//            minY = min(dataPoint.a, minY)
//            minT = min(dataPoint.timestamp, minT)
//        }
//
//        return ChartConfigXY(
//            xAxisConfig: ChartAxisConfig(from: minT, to: maxT, by: 1),
//            yAxisConfig: ChartAxisConfig(from: minY, to: maxY, by: 1)
//        )
//    }
//
//    func getChart() -> LineChart {
//        let data = transformData()
//        let frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
//
//        return LineChart(frame: frame, chartConfig: getChartConfig(), xTitle: "X", yTitle: "Y", lines: [
//            (chartPoints: data.a, color: UIColor.red)
//            ])
//    }
//
//    func updateChart() {
//        print("updating the chart")
//        print(self.motionDataPoints)
//        for view in self.subviews {
//            view.removeFromSuperview()
//        }
//
//        self.addSubview(getChart().view)
//        self.backgroundColor = UIColor.black
//    }
}
