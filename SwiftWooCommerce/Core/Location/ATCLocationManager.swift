//
//  ATCLocationManager.swift
//  CupertinoKit
//
//  Created by Florian Marcu on 6/16/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import CoreLocation
import UIKit

protocol ATCLocationManagerDelegate: class {
    func locationManager(_ locationManager: ATCLocationManager, didReceive location: ATCLocation)
}

class ATCLocationManager: NSObject, CLLocationManagerDelegate {
    let manager: CLLocationManager
    weak var delegate: ATCLocationManagerDelegate?

    override init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
        manager.distanceFilter = kCLDistanceFilterNone
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }

    func requestWhenInUsePermission() {
        manager.requestWhenInUseAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let clLocation = locations.first {
            let location = ATCLocation(longitude: clLocation.coordinate.longitude,
                                       latitude: clLocation.coordinate.latitude)
            delegate?.locationManager(self, didReceive: location)
        }
    }
}
