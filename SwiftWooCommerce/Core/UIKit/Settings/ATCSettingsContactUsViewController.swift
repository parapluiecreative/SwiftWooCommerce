//
//  ATCSettingsContactUsViewController.swift
//  DatingApp
//
//  Created by Florian Marcu on 2/2/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//
//
//

import UIKit

class ATCSettingsContactUsViewController: QuickTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contact".localizedCore
        
        tableContents = [
            Section(title: "Contact".localizedCore, rows: [
                NavigationRow(text: "Our address".localizedCore, detailText: .subtitle("1412 Steiner Street, San Fracisco, CA, 94115"), icon: .named("globe")),
                NavigationRow(text: "E-mail us".localizedCore, detailText: .value1("office@shopertino.com"), icon: .named("time"), action: { (row) in
                    guard let email = URL(string: "mailto://office@shopertino.com") else { return }
                    UIApplication.shared.open(email)
                })
            ], footer: "Our business hours are Mon - Fri, 10am - 5pm, PST."),
            Section(title: "", rows: [
                TapActionRow(text: "Call Us".localizedCore, action: { (row) in
                    guard let number = URL(string: "tel://6504859694") else { return }
                    UIApplication.shared.open(number)
                })
            ]),
        ]
    }
}
