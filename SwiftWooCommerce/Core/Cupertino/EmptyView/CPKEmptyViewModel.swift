//
//  CPKEmptyViewModel.swift
//  ClassifiedsApp
//
//  Created by Florian Marcu on 9/25/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
import SwiftUI

struct CPKEmptyViewModel {
    let image: UIImage?
    let title: String?
    let description: String?
    let callToAction: String?
    var callToActionTextColor: Color = .white
    var callToActionBackgroundColor: Color = Color.blue.opacity(0.9)
    var bottomPadding: CGFloat = 0
}
