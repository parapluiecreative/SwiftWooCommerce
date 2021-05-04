//
//  ATCFacebookUser.swift
//  AppTemplatesCore
//
//  Created by Florian Marcu on 2/2/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

class ATCFacebookUser: ATCGenericBaseModel {

    var firstName: String?
    var lastName: String?
    var email: String?
    var id: String?
    var profilePicture: String?

    var description: String {
        return firstName ?? ""
    }

    required init(jsonDict: [String: Any]) {
//        firstName       <- map["first_name"]
//        lastName        <- map["last_name"]
//        email           <- map["email"]
//        id              <- map["id"]
//        profilePicture  <- map["picture.data.url"]
    }
}
