//
//  RideListCollectionViewController.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 11/3/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit
import CoreData

protocol RideSelectionDelegate: class {
    func rideSelected(_ ride: Ride)
}

protocol ParkSelectionDelegate {
    func parkSelected(_ park: Park)
}

private let reuseIdentifier = RIDE_COLLECTION_VIEW_CELL

private let CELL_MIN_WIDTH = CGFloat(150)

class RideListCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    weak var delegate: RideSelectionDelegate?
    var fetch: NSFetchedResultsController<Ride>? = nil
    var park: Park? = nil {
        didSet {
            self.navigationItem.title = park?.name

            self.loadRides()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let flowLayout = (self.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0

        self.navigationItem.title = park?.name
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetch?.fetchedObjects?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RideCollectionViewCell

        cell.ride = fetch?.fetchedObjects?[indexPath.row]
    
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frameWidth = collectionView.frame.width
        let count: Int = Int(frameWidth / CELL_MIN_WIDTH)
        let size: CGFloat = frameWidth / CGFloat(count)

        return CGSize(width: size, height: size)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedRide = fetch?.fetchedObjects?[indexPath.row] else { return }
        delegate?.rideSelected(selectedRide)
        if let detailViewController = delegate as? RideDetailViewController {
            splitViewController?.showDetailViewController(detailViewController, sender: nil)
        }
    }

    func loadRides() {
        self.park?.loadRides {
            DispatchQueue.main.async {
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                self.updateFetch()
            }
        }
    }

    func updateFetch(reload: Bool = true) {
        guard let park = self.park else {
            self.fetch = nil
            return
        }

        let request = NSFetchRequest<Ride>(entityName: "Ride")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let id = park.id
        request.predicate = NSPredicate(format: "park.id == %@", "\(id)")
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let fetch = NSFetchedResultsController<Ride>(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)

        try! fetch.performFetch()
        self.fetch = fetch

        if reload {
            collectionView.reloadData()
        }
    }
}
