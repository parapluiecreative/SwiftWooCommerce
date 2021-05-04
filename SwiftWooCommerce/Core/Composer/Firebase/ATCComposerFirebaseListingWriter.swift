//
//  ATCComposerFirebaseListingWriter.swift
//  ListingApp
//
//  Created by Florian Marcu on 10/9/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage
import UIKit

let kListingCollectionDidUpdateNotificationName = Notification.Name("kListingCollectionDidUpdateNotificationName")

class ATCComposerFirebaseListingWriter {
    let tableName: String
    let reviewsTableName: String

    init(tableName: String, reviewsTableName: String) {
        self.tableName = tableName
        self.reviewsTableName = reviewsTableName
    }

    func save(state: ATCComposerState, user: ATCUser?, completion: @escaping () -> Void) {
        var filters: [String: String] = [:]
        state.filters?.forEach({ (filter) in
            filters[filter.title] = filter.selectedOption?.name
        })

        let photos = state.images ?? []
        var dictionary: [String: Any] = [
            "categoryID": state.category?.id ?? "",
            "categoryPhoto": state.category?.imageURLString ?? "",
            "categoryTitle": state.category?.title ?? "",
            "title": state.title ?? "",
            "createdAt": Date(),
            "description": state.description ?? "",
            "latitude": state.latitude ?? 0,
            "longitude": state.longitude ?? 0,
            "location": state.location ?? "",
            "filters": filters,
            "price": state.price ?? "",
            ]

        if let user = user {
            dictionary["author"] = user.uid ?? ""
            dictionary["authorProfilePic"] = user.profilePictureURL ?? ""
            dictionary["authorName"] = user.fullName()
        }

        var photosURLs: [String] = []
        var uploadedPhotos = 0
        photos.forEach { (image) in
            self.uploadImage(image, completion: {[weak self] (url) in
                guard let `self` = self else { return }
                if let urlString = url?.absoluteString {
                    photosURLs.append(urlString)
                }
                uploadedPhotos += 1
                if (uploadedPhotos == photos.count) {
                    let newDocRef = Firestore.firestore().collection(self.tableName).document()
                    dictionary["id"] = newDocRef.documentID
                    dictionary["photos"] = photosURLs
                    dictionary["photo"] = photosURLs[0] ?? ""
                    newDocRef.setData(dictionary)
                    NotificationCenter.default.post(name: kListingCollectionDidUpdateNotificationName, object: nil)
                    completion()
                }
            })
        }
    }

    func remove(listing: ATCListing, completion: @escaping (_ success: Bool) -> Void) {
        let db = Firestore.firestore()
        let collectionRef = db.collection(self.reviewsTableName)
        let documentRef = collectionRef.whereField("entityID", isEqualTo: "\(listing.id)")

        // Remove Reviews
        documentRef.getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
            } else {
                guard let snapshot = snapshot else { return }
                for document in snapshot.documents {
                    document.reference.delete()
                }
            }
        }

        // Remove Listing
        let listingRef = db.collection(tableName).whereField("id", isEqualTo: "\(listing.id)")
        listingRef.getDocuments { (snapshot, error) in
            if error != nil {
                completion(false)
            } else {
                guard let snapshot = snapshot else {
                    completion(true)
                    return
                }
                for document in snapshot.documents {
                    document.reference.delete()
                    NotificationCenter.default.post(name: kListingCollectionDidUpdateNotificationName, object: nil)
                    completion(true)
                }
                if snapshot.documents.count == 0 {
                    completion(true)
                }
            }
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
