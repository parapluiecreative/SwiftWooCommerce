//
//  ATCEcommerceProfileManager.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/18/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ATCProfileManagerDelegate: class {
    func profileEditManager(_ manager: ATCProfileManager, didFetch user: ATCUser) -> Void
    func profileEditManager(_ manager: ATCProfileManager, didUpdateProfile success: Bool) -> Void
}

protocol ATCProfileManager: class {
    var delegate: ATCProfileManagerDelegate? {get set}
    func fetchProfile(for user: ATCUser) -> Void
    func update(profile: ATCUser,
                email: String,
                firstName: String,
                lastName: String,
                phone: String) -> Void
    func updateUserPresence(profile: ATCUser, isOnline: Bool) -> Void
}

