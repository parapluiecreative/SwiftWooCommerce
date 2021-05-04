//
//  ATCCreateAddressViewController.swift
//  Shopertino
//
//  Created by Mayil Kannan on 15/09/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import Eureka
import UIKit
import FirebaseFirestore

protocol ATCCreateAddressViewControllerDelegate: class {
    func createAddressVCDidUpdateAddress() -> Void
}

class ATCCreateAddressViewController: FormViewController {
    var user: ATCUser?
    var address: ATCAddress?
    weak var delegate: ATCCreateAddressViewControllerDelegate?
    let dsProvider: ATCEcommerceDataSourceProvider?

    init(user: ATCUser?,
         dsProvider: ATCEcommerceDataSourceProvider?) {
        self.user = user
        self.dsProvider = dsProvider
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        self.title = "Add Address"
        setAddressUI()
    }

    private func setAddressUI() {
        form +++ Eureka.Section("Add Address")
            <<< Eureka.TextRow(){ row in
                row.title = "First Name"
                row.placeholder = "First Name"
                row.value = address?.firstName
                row.tag = "firstname"
            }
            <<< Eureka.TextRow(){ row in
                row.title = "Last Name"
                row.placeholder = "Last Name"
                row.value = address?.lastName
                row.tag = "lastname"
            }
            <<< Eureka.TextRow(){ row in
                row.title = "Address"
                row.placeholder = "Address"
                row.value = address?.line1
                row.tag = "address"
            }
            <<< Eureka.TextRow(){ row in
                row.title = "Apt."
                row.placeholder = "Apt."
                row.value = address?.line2
                row.tag = "apt"
            }
            <<< Eureka.TextRow(){ row in
                row.title = "Country"
                row.placeholder = "Country"
                row.value = address?.country
                row.tag = "country"
            }
            <<< Eureka.TextRow(){ row in
                row.title = "Zip Code"
                row.placeholder = "Zip Code"
                row.value = address?.postalCode
                row.tag = "zipcode"
            }
            <<< Eureka.TextRow(){ row in
                row.title = "City"
                row.placeholder = "City"
                row.value = address?.city
                row.tag = "city"
            }
            <<< Eureka.TextRow(){ row in
                row.title = "State"
                row.placeholder = "State"
                row.value = address?.state
                row.tag = "state"
            }
            <<< Eureka.TextRow(){ row in
                row.title = "Phone"
                row.placeholder = "Phone"
                row.value = address?.phone
                row.tag = "phone"
            }
    }

    @objc private func didTapDone() {
        var firstName = ""
        var lastName = ""
        var address1 = ""
        var apt = ""
        var country = ""
        var zipcode = ""
        var city = ""
        var state = ""
        var phone = ""
        
        if let row = form.rowBy(tag: "firstname") as? TextRow {
            firstName = row.value ?? ""
        }
        if let row = form.rowBy(tag: "lastname") as? TextRow {
            lastName = row.value ?? ""
        }
        if let row = form.rowBy(tag: "address") as? TextRow {
            address1 = row.value ?? ""
        }
        if let row = form.rowBy(tag: "apt") as? TextRow {
            apt = row.value ?? ""
        }
        if let row = form.rowBy(tag: "country") as? TextRow {
            country = row.value ?? ""
        }
        if let row = form.rowBy(tag: "zipcode") as? TextRow {
            zipcode = row.value ?? ""
        }
        if let row = form.rowBy(tag: "city") as? TextRow {
            city = row.value ?? ""
        }
        if let row = form.rowBy(tag: "state") as? TextRow {
            state = row.value ?? ""
        }
        if let row = form.rowBy(tag: "phone") as? TextRow {
            phone = row.value ?? ""
        }
        
        if let userID = user?.uid {
            if let address = address, let addressID = address.addressID {
                Firestore.firestore().collection("users").document(userID).updateData(
                    ["shippingAddress.\(addressID)" :
                        [
                            "addressID": addressID,
                            "firstName": firstName,
                            "lastName": lastName,
                            "line1": address1,
                            "line2": apt,
                            "country": country,
                            "postalCode": zipcode,
                            "city": city,
                            "state": state,
                            "phone": phone
                        ]
                    ]
                ) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                        let alert = UIAlertController(title: "Error",
                                                      message: err.localizedDescription,
                                                      preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    } else {
                        print("Successfully updated")
                        self.delegate?.createAddressVCDidUpdateAddress()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                let addressID = UUID().uuidString
                Firestore.firestore().collection("users").document(userID).setData([
                    "shippingAddress": [
                        addressID: [
                            "addressID": addressID,
                            "firstName": firstName,
                            "lastName": lastName,
                            "line1": address1,
                            "line2": apt,
                            "country": country,
                            "postalCode": zipcode,
                            "city": city,
                            "state": state,
                            "phone": phone
                        ]
                    ]
                ], merge: true) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                        let alert = UIAlertController(title: "Error",
                                                      message: err.localizedDescription,
                                                      preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    } else {
                        print("Successfully updated")
                        self.delegate?.createAddressVCDidUpdateAddress()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }

    @objc private func didTapCancel() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
