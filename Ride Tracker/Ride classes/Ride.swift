//
//  Ride.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 10/18/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit

extension Ride {
    var photoName: String {
        get {
            return "\(self.id)"
        }
    }

    var photo: UIImage? {
        get {
            if let photoData = self.photoData,
                let photo = UIImage(data: photoData) {
                return photo
            }

            if let photo = UIImage(named: getDocumentsDirectory().appendingPathComponent(self.photoName).path) {
                self.photoData = photo.pngData()
                return photo
            }

            return nil
        }
    }

    func set(imageView view: UIImageView, shouldUpdateImage: RefBool) {
        let activity = UIActivityIndicatorView(frame: view.frame)
        activity.style = .gray
        activity.startAnimating()
        view.addSubview(activity)

        DispatchQueue.global(qos: .userInitiated).async {
            if let photo = self.photo {
                DispatchQueue.main.async {
                    activity.removeFromSuperview()
                    if shouldUpdateImage.val {
                        view.image = photo
                    }
                }
            } else {
                if let url = self.photoUrl {
                    getImage(from: url, onCompletion: { (image) in
                        if let image = image {
                            // Save the image localally
                            if let data = image.pngData() {
                                let filename = getDocumentsDirectory().appendingPathComponent(self.photoName)
                                try? data.write(to: filename)
                                // Put the image data into the photoData var
                                self.photoData = data
                            }
                            // Set the image view image to be the fetched image
                            DispatchQueue.main.async {
                                activity.removeFromSuperview()
                                if shouldUpdateImage.val {
                                    view.image = image
                                }
                            }
                        }
                    })
                }
            }
        }
    }
}

fileprivate func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}
