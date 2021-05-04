//
//  SettingsViewController.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/25/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ProfileSettingsViewController: QuickTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings".localizedInApp

        tableContents = [
            Section(title: "Security", rows: [
                SwitchRow(text: "Enable Face ID / Touch ID Login".localizedInApp, switchValue: true, action: { _ in }),
                ], footer: "While turned off, you will still be able to login with your password.".localizedInApp),
            Section(title: "Push Notifications".localizedInApp, rows: [
                SwitchRow(text: "Order updates".localizedInApp, switchValue: true, action: { _ in }),
                SwitchRow(text: "New arrivals".localizedInApp, switchValue: false, action: { _ in }),
                SwitchRow(text: "Promotions".localizedInApp, switchValue: true, action: { _ in }),
                SwitchRow(text: "Sales alerts".localizedInApp, switchValue: false, action: { _ in }),
                ]),
            Section(title: "Account".localizedInApp, rows: [
                TapActionRow(text: "Support".localizedInApp, action: { [weak self] in self?.showAlert($0) }),
                TapActionRow(text: "Log Out".localizedInApp, action: { (row) in
                    NotificationCenter.default.post(name: kLogoutNotificationName, object: nil)
                })
                ]),
        ]
    }

    // MARK: - Actions
    private func showAlert(_ sender: Row) {
        // ...
    }

    private func didToggleSelection() -> (Row) -> Void {
        return { row in
            // ...
        }
    }
}
