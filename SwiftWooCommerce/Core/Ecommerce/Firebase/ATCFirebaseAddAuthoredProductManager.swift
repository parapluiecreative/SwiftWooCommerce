//
//  ATCFirebaseAddAuthoredProductManager.swift
//  Shopertino
//
//  Created by Duy Bui on 1/29/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage
import UIKit

let kShopertinoCollectionDidUpdateNotificationName = Notification.Name("kShopertinoCollectionDidUpdateNotificationName")

class ATCFirebaseAddAuthoredProductManager: ATCAddAuthoredProductManagerProtocol {
    
    var tableName: String
    init(tableName: String) {
        self.tableName = tableName
    }
    
    func addAuthoredProductManagerProtocol(userId: String?, product: Product?, completion: @escaping (Bool) -> Void) {
        guard let userId = userId, let product = product, let categoryId = product.categoryID else {
            completion(false)
            return
        }
        let newDocRef = Firestore.firestore().collection(tableName).document()
        var products: [String: Any] = [
            "vendorID": userId,
            "name": product.title,
            "description": product.productDescription,
            "category": categoryId,
            "price": product.price
        ]
        if let photos = product.uploadImages {
            var photosURLs: [String] = []
            var uploadedPhotos = 0
            photos.forEach { (image) in
                self.uploadImage(image, completion: {(url) in
                    if let urlString = url?.absoluteString {
                        photosURLs.append(urlString)
                    }
                    uploadedPhotos += 1
                    if (uploadedPhotos == photos.count) {
                        products["id"] = newDocRef.documentID
                        products["images"] = photosURLs
                        products["image_url"] = photosURLs[0]
                        newDocRef.setData(products)
                        NotificationCenter.default.post(name: kShopertinoCollectionDidUpdateNotificationName, object: nil)
                        completion(true)
                    }
                })
            }
        } else {
            newDocRef.setData(products)
            NotificationCenter.default.post(name: kShopertinoCollectionDidUpdateNotificationName, object: nil)
            completion(true)
        }
    }
    
    private func uploadImage(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        let storage = Storage.storage().reference()
        guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.4) else {
            completion(nil)
            return
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        let ref = storage.child(tableName).child(imageName)
        ref.putData(data, metadata: metadata) { meta, error in
            ref.downloadURL { (url, error) in
                completion(url)
            }
        }
    }
}
