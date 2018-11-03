//
//  Park.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 10/18/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit
import CoreData

fileprivate struct ParkJson {
    let id: Int64
    let name: String
    let latitude: Double
    let longitude: Double

    static func create(from json: [String: Any]) -> ParkJson? {
        if let id = json["id"] as? Int64,
            let name = json["name"] as? String,
            let location = json["location"] as! [String : Double]?,
            let latitude = location["latitude"],
            let longitude = location["longitude"] {
            return ParkJson(id: id, name: name, latitude: latitude, longitude: longitude)
        }

        return nil
    }
}

fileprivate struct RideJson {
    let id: Int64
    let name: String
    let latitude: Double
    let longitude: Double
    let photoUrl: String
    let description: String
    let minimumHeight: Int?
    let maximumHeight: Int?
    let updatedTime: Date
    let closed: Bool
    let type: String
    let isUpcharge: Bool

    static func parse(int: String?) -> Int? {
        if int == nil {
            return nil
        }
        return Int(int!)
    }

    static func create(from json: [String : String]) -> RideJson? {
        if  let id = Int64(json["id"]!),
            let name = json["name"],
            let latitude = Double(json["latitude"]!),
            let longitude = Double(json["longitude"]!),
            let photoUrl = json["photoUrl"],
            let description = json["description"],
            let minimumHeight = json["minimumHeight"],
            let maximumHeight = json["maximumHeight"],
            let updatedTimeString = json["updated"],
            let closedString = json["closed"],
            let type = json["type"],
            let isUpchargeString = json["upchargeAttraction"] {

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateUpdated = formatter.date(from: updatedTimeString)!

            return RideJson(id: id,
                            name: name,
                            latitude: latitude,
                            longitude: longitude,
                            photoUrl: photoUrl,
                            description: description,
                            minimumHeight: parse(int: minimumHeight),
                            maximumHeight: parse(int: maximumHeight),
                            updatedTime: dateUpdated,
                            closed: closedString == "1",
                            type: type,
                            isUpcharge: isUpchargeString == "1")
        }

        return nil
    }
}

func loadParkClasses() {
    let parks = loadJson()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    for park in parks {
        // Check for Core Data park with same id
        let fetchRequest = NSFetchRequest<Park>(entityName: "Park")
        fetchRequest.predicate = NSPredicate(format: "id = %@", argumentArray: [park.id])

        do {
            let result = try context.fetch(fetchRequest)

            if result.count == 0 {
                _ = createParkObject(from: park, with: context)
            }

            if result.count == 1 {
                let object = result[0]
                object.name = park.name
                object.latitude = park.latitude
                object.longitude = park.longitude
            }

            if result.count > 1 {
                fatalError("More than one park with id \(park.id) in the store!")
            }
        } catch {
            _ = createParkObject(from: park, with: context)
        }

        try! context.save()
    }
}

fileprivate func createParkObject(from json: ParkJson, with context: NSManagedObjectContext) -> Park {
    let park = Park(context: context)
    park.id = json.id
    park.name = json.name
    park.latitude = json.latitude
    park.longitude = json.longitude

    return park
}

fileprivate func loadJson() -> [ParkJson] {
    let file = Bundle.main.url(forResource: "parks", withExtension: "json")!
    let data = (try? Data(contentsOf: file))!
    let json = (try? JSONSerialization.jsonObject(with: data) as! [[String : Any]])!

    var parks: [ParkJson] = []

    for park in json {
        if let park = ParkJson.create(from: park) {
            parks.append(park)
        }
    }

    return parks
}

fileprivate func update(ride: Ride, from json: RideJson) {
    guard ride.id == json.id else { return }

    ride.name = json.name
    ride.latitude = json.latitude
    ride.longitude = json.longitude
    ride.photoUrl = URL(string: json.photoUrl)
    ride.rideDescription = json.description
    if let minimumHeight = json.minimumHeight {
        ride.minimumHeight = NSNumber(integerLiteral: minimumHeight)
    }
    if let maximumHeight = json.maximumHeight {
        ride.maximumHeight = NSNumber(integerLiteral: maximumHeight)
    }
    ride.lastUpdated = json.updatedTime
    ride.closed = json.closed
    ride.type = json.type
    ride.isUpcharge = json.isUpcharge
}

extension Park {
    func loadRides(onCompletion handler: @escaping () -> Void) {
        // I fucking hate this. This should really use ssl, but for some reason,
        // its easier for an iOS app to allow acccessing insecure conections
        // than a site with a self signed cert.
        let url = URL(string: "http://ridetracker.revoltapplications.com/rides.php?parkId=\(self.id)")!
        getJson(from: url) { (json) in
            DispatchQueue.main.async {
                guard let rides = json as? [[String : String]] else { return }
                for ride in rides {
                    if let rideJson = RideJson.create(from: ride) {
                        if let rideEntity = self.getRide(by: rideJson.id) {
                            if rideEntity.lastUpdated != rideJson.updatedTime {
                                // Update the existing entity
                                update(ride: rideEntity, from: rideJson)
                            }
                        } else {
                            // Create a new entity
                            let newRide = Ride(context: CONTEXT)
                            newRide.id = rideJson.id
                            newRide.park = self
                            update(ride: newRide, from: rideJson)
                        }
                    }
                }
                handler()
            }
        }
    }

    func getRide(by id: Int64) -> Ride? {
        let request = NSFetchRequest<Ride>(entityName: "Ride")
        request.predicate = NSPredicate(format: "id = %@ AND park.id = %@", argumentArray: [id, self.id])
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]

        let fetch = NSFetchedResultsController<Ride>(fetchRequest: request, managedObjectContext: CONTEXT, sectionNameKeyPath: nil, cacheName: nil)

        try! fetch.performFetch()
        return (fetch.fetchedObjects?.count ?? 0) > 0 ? fetch.fetchedObjects?[0] : nil
    }
}
