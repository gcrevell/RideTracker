//
//  Ride.swift
//  Ride Tracker
//
//  Created by Gabriel Revells on 10/18/18.
//  Copyright © 2018 Gabriel Revells. All rights reserved.
//

import UIKit

extension Ride {
    fileprivate var photoName: String {
        get {
            return "\(self.id)"
        }
    }

    func getPhoto(handler: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let photo = self.getPhotoFromMemory() {
                DispatchQueue.main.async {
                    handler(photo)
                }
                return
            }

            if let photo = self.getLocalPhoto() {
                self.photoData = photo.pngData()
                DispatchQueue.main.async {
                    handler(photo)
                }
                return
            }

            self.fetchPhoto(handler: { (photo) in
                if let data = photo?.pngData() {
                    let filename = getDocumentsDirectory().appendingPathComponent(self.photoName)
                    try? data.write(to: filename)
                    // Put the image data into the photoData var
                    self.photoData = data
                }
                DispatchQueue.main.async {
                    handler(photo)
                }
            })
        }
    }

    fileprivate func getPhotoFromMemory() -> UIImage? {
        if let photoData = self.photoData,
            let photo = UIImage(data: photoData) {
            return photo
        }

        return nil
    }

    fileprivate func getLocalPhoto() -> UIImage? {
        return UIImage(named: getDocumentsDirectory().appendingPathComponent(self.photoName).path)
    }

    fileprivate func fetchPhoto(handler: @escaping (UIImage?) -> Void) {
        if let url = self.photoUrl {
            getImage(from: url, onCompletion: { (image) in
                handler(image)
            })
        }
    }

    func set(imageView view: UIImageView, shouldUpdateImage: RefBool) {
        let activity = UIActivityIndicatorView(frame: view.frame)
        activity.style = .gray
        activity.startAnimating()
        view.addSubview(activity)

        getPhoto { (photo) in
            activity.removeFromSuperview()
            if shouldUpdateImage.val {
                view.image = photo
            }
        }

//        DispatchQueue.global(qos: .userInitiated).async {
//            if let photo = self.photo {
//                DispatchQueue.main.async {
//                    activity.removeFromSuperview()
//                    if shouldUpdateImage.val {
//                        view.image = photo
//                    }
//                }
//            } else {
//                if let url = self.photoUrl {
//                    getImage(from: url, onCompletion: { (image) in
//                        if let image = image {
//                            // Save the image localally
//                            if let data = image.pngData() {
//                                let filename = getDocumentsDirectory().appendingPathComponent(self.photoName)
//                                try? data.write(to: filename)
//                                // Put the image data into the photoData var
//                                self.photoData = data
//                            }
//                            // Set the image view image to be the fetched image
//                            DispatchQueue.main.async {
//                                activity.removeFromSuperview()
//                                if shouldUpdateImage.val {
//                                    view.image = image
//                                }
//                            }
//                        }
//                    })
//                }
//            }
//        }
    }
}

fileprivate func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}
