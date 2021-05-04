//
//  ATCAccountDetailsViewController.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/18/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Eureka
import UIKit

protocol ATCAccountDetailsViewControllerDelegate: class {
    func accountDetailsVCDidUpdateProfile() -> Void
    func accountDetailsVCUpdateProfile(updatedUser: ATCUser) -> Void
}

extension ATCAccountDetailsViewControllerDelegate {
    func accountDetailsVCUpdateProfile(updatedUser: ATCUser) { }
}

class ATCAccountDetailsViewController: FormViewController, ATCProfileManagerDelegate {
    var user: ATCUser
    var manager: ATCFirebaseProfileManager?
    var profile: ATCUser? = nil
    let cancelEnabled: Bool

    weak var delegate: ATCAccountDetailsViewControllerDelegate?

    init(user: ATCUser,
         manager: ATCFirebaseProfileManager?,
         cancelEnabled: Bool) {
        self.user = user
        self.manager = manager
        self.cancelEnabled = cancelEnabled
        super.init(nibName: nil, bundle: nil)
        self.manager?.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        if (cancelEnabled) {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        }
        if let manager = manager {
            manager.fetchProfile(for: user)
        } else {
            didUpdateUser()
        }
        self.title = "Edit Profile"
    }

    func profileEditManager(_ manager: ATCProfileManager, didFetch user: ATCUser) -> Void {
        self.user = user
        self.profile = user
        self.didUpdateUser()
    }

    func profileEditManager(_ manager: ATCProfileManager, didUpdateProfile success: Bool) -> Void {
        if (success) {
            delegate?.accountDetailsVCDidUpdateProfile()
            self.dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error",
                                          message: "There was an issue while updating the profile. Please try again.",
                                          preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }

    private func didUpdateUser() {
        form +++ Eureka.Section("Public Profile")
            <<< Eureka.TextRow(){ row in
                row.title = "First Name"
                row.placeholder = "Your first name"
                row.value = user.firstName
                row.tag = "firstname"
            }
            <<< Eureka.TextRow(){ row in
                row.title = "Last Name"
                row.placeholder = "Your last name"
                row.value = user.lastName
                row.tag = "lastname"
            }
            +++ Eureka.Section("Private Details")
            <<< TextRow(){ row in
                row.title = "E-mail Address"
                row.placeholder = "Your e-mail address"
                row.value = user.email
                row.tag = "email"
            }
            <<< Eureka.TextRow(){ row in
                row.title = "Phone Number"
                row.placeholder = "Your phone number"
                row.value = user.phoneNumber
                row.tag = "phone"
        }
    }

    @objc private func didTapDone() {
        guard let profile = profile else { return }

        var lastName = ""
        var firstName = ""
        var email = ""
        var phone = ""

        if let row = form.rowBy(tag: "lastname") as? TextRow {
            lastName = row.value ?? ""
        }
        if let row = form.rowBy(tag: "firstname") as? TextRow {
            firstName = row.value ?? ""
        }
        if let row = form.rowBy(tag: "email") as? TextRow {
            email = row.value ?? ""
        }
        if let row = form.rowBy(tag: "phone") as? TextRow {
            phone = row.value ?? ""
        }
        
        self.manager?.update(profile: profile,
                             email: email,
                             firstName: firstName,
                             lastName: lastName,
                             phone: phone)
    }

    @objc private func didTapCancel() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
