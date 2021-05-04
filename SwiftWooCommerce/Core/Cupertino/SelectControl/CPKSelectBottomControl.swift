//
//  CPKSelectBottomControl.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 11/27/19.
//  Copyright © 2019 iOS App Templates. All rights reserved.
//

import SwiftUI

protocol CPKSelectBottomControlDelegate: class {
    func didPickOption(_ option: CPKSelectOptionModel)
    func didDismiss()
}

struct CPKSelectBottomControl: View {
    @State var options: [CPKSelectOptionModel]
    @State var tintColor: UIColor
    @State var isOpen: Bool

    weak var delegate: CPKSelectBottomControlDelegate?

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
        }.sheet(isPresented: self.$isOpen, onDismiss: {
            self.isOpen = false
            self.delegate?.didDismiss()
        }, content: {
            CPKSelectControl(options: self.options, tintColor: self.tintColor, isOpen: self.isOpen, delegate: self)
        })
    }
}

extension CPKSelectBottomControl: CPKSelectControlDelegate {
    func didTapOption(_ option: CPKSelectOptionModel) {
    
        self.isOpen = false
        self.delegate?.didPickOption(option)
    }
}
