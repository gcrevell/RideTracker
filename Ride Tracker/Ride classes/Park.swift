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

func loadParkClasses() {
    let parks = loadJson()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    print(parks)

    for park in parks {
        // Check for Core Data park with same id
        let fetchRequest = NSFetchRequest<Park>(entityName: "Park")
        fetchRequest.predicate = NSPredicate(format: "id = %@", argumentArray: [park.id])

        do {
            let result = try context.fetch(fetchRequest)

            if result.count == 0 {
                createParkObject(from: park, with: context)
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
            createParkObject(from: park, with: context)
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
