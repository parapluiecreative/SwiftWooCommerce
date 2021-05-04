//
//  ATCLocation.swift
//  DatingApp
//
//  Created by Florian Marcu on 6/16/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import CoreLocation
import UIKit

class ATCLocation: NSObject, ATCGenericBaseModel, NSCoding {

    var longitude: Double
    var latitude: Double

    public init(longitude: Double, latitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public init(representation: [String: Any]) {
        self.longitude = representation["longitude"] as? Double ?? 0
        self.latitude = representation["latitude"] as? Double ?? 0
    }

    required public init(jsonDict: [String: Any]) {
        fatalError()
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(longitude, forKey: "longitude")
        aCoder.encode(latitude, forKey: "latitude")
    }

    public convenience required init?(coder aDecoder: NSCoder) {
        self.init(longitude: aDecoder.decodeObject(forKey: "longitude") as? Double ?? 0.0,
                  latitude: aDecoder.decodeObject(forKey: "latitude") as? Double ?? 0.0)
    }

    var representation: [String : Any] {
        let rep: [String : Any] = [
            "longitude": longitude,
            "latitude": latitude
        ]
        return rep
    }

    func isInRange(to location: ATCLocation, by distance: Double) -> Bool {
        return (self.distance(to: location) / 1609.34 <= distance)
    }

    func stringDistance(to location: ATCLocation) -> String {
        let distance = Int(self.distance(to: location) / 1609.34)
        return String(distance) + " miles"
    }

    fileprivate func distance(to otherLocation: ATCLocation) -> Double {
        let myLocation = CLLocation(latitude: latitude, longitude: longitude)
        let theirLocation = CLLocation(latitude: otherLocation.latitude, longitude: otherLocation.longitude)
        return myLocation.distance(from: theirLocation)
    }
}
