//
//  RideMapCollectionViewCell.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 11/9/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit
import MapKit

class RideMapCollectionViewCell: FloatingCollectionViewCell, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!

    var rides: [Ride]? {
        didSet {
            mapView.removeAnnotations(mapView.annotations)
            guard let rides = rides else {
                return
            }

            for ride in rides {
                let annotation = RideAnnotation(with: ride)
                self.mapView.addAnnotation(annotation)
            }

            mapView.showAnnotations(mapView.annotations, animated: false)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        mapView.showsPointsOfInterest = false
        mapView.showsUserLocation = true
        mapView.delegate = self
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
        marker.clusteringIdentifier = "ride"
        // Set image to generic icon
        marker.glyphImage = UIImage(named: "Park Icon")
        marker.glyphText = nil

        if let _ = annotation as? MKClusterAnnotation {
            // Set color to group color #96628E
            marker.markerTintColor = UIColor(red: 150.0/255.0, green: 98.0/255.0, blue: 142.0/255.0, alpha: 1.0)
        }

        if let annotation = annotation as? RideAnnotation {
            marker.glyphImage = annotation.ride.rideType?.getIcon()
            marker.markerTintColor = annotation.ride.rideType?.getMapPinColor()
        }

        return marker
    }
}
