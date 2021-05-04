//
//  ATCAddress.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 11/26/19.
//  Copyright © 2019 iOS App Templates. All rights reserved.
//

import UIKit
import CoreLocation

class ATCAddress: ATCGenericBaseModel {

    var firstName: String?
    var lastName: String?
    var name: String?
    var line1: String?
    var line2: String?
    var city: String?
    var state: String?
    var postalCode: String?
    var country: String?
    var phone: String?
    var email: String?
    var location: ATCLocation? = nil
    var addressID: String?

    convenience init(firstName: String? = nil,
                     lastName: String? = nil,
                     name: String? = nil,
                     line1: String? = nil,
                     line2: String? = nil,
                     city: String? = nil,
                     state: String? = nil,
                     postalCode: String? = nil,
                     country: String? = nil,
                     phone: String? = nil,
                     email: String? = nil,
                     location: ATCLocation? = nil,
                     addressID: String? = nil) {
        self.init(jsonDict: [:])
        self.firstName = firstName
        self.lastName = lastName
        self.name = name
        self.line1 = line1
        self.line2 = line2
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
        self.phone = phone
        self.email = email
        self.location = location
        self.addressID = addressID
    }

    required init(jsonDict: [String: Any]) {
        addressID = jsonDict["addressID"] as? String
        name = jsonDict["name"] as? String
        firstName = jsonDict["firstName"] as? String
        lastName = jsonDict["lastName"] as? String
        if let firstName = firstName, let lastName = lastName {
            self.name = firstName.isEmpty ? lastName : (firstName + " " + lastName)
        }
        line1 = jsonDict["line1"] as? String
        line2 = jsonDict["line2"] as? String
        city = jsonDict["city"] as? String
        postalCode = jsonDict["postalCode"] as? String
        country = jsonDict["country"] as? String
        state = jsonDict["state"] as? String
        phone = jsonDict["phone"] as? String
        email = jsonDict["email"] as? String
        var location: ATCLocation? = nil
        if let locationDict = jsonDict["location"] as? [String: Any] {
            location = ATCLocation(representation: locationDict)
        }
        self.location = location
    }

    var description: String {
        var address = (
            (String.isEmpty(name) ? "" : (name! + ", ")) +
                (String.isEmpty(line1) ? "" : (line1! + ", ")) +
                (String.isEmpty(line2) ? "" : (line2! + ", ")) +
                (String.isEmpty(city) ? "" : (city! + ", ")) +
                (String.isEmpty(postalCode) ? "" : (postalCode! + ", ")) +
                (String.isEmpty(country) ? "" : (country! + ", ")) +
                (String.isEmpty(phone) ? "" : (phone! + ", ")) +
                (String.isEmpty(email) ? "" : (email! + ", ")))
        if (address.count < 4) {
            return address
        }
        address = String(address.dropLast())
        address = String(address.dropLast())
        return String(address)
    }

    var fullAddress: String {
        let address = (
                (String.isEmpty(line1) ? "" : (line1! + ", ")) +
                (String.isEmpty(line2) ? "" : (line2! + ", ")) +
                (String.isEmpty(city) ? "" : (city! + ", ")) +
                (String.isEmpty(postalCode) ? "" : (postalCode! + "")))
        return String(address)
    }
    
    var representation: [String : Any] {
        var rep: [String : Any] = [
            "name": name ?? "",
            "line1": line1 ?? "",
            "line2": line2 ?? "",
            "city": city ?? "",
            "postalCode": postalCode ?? "",
            "country": country ?? "",
            "phone": phone ?? "",
            "email": email ?? "",
        ]
        if let location = location {
            rep["location"] = location.representation
        }
        return rep
    }
}
