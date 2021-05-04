//
//  CPKOverlayStyleProtocol.swift
//  CupertinoKit
//
//  Created by Mayil Kannan on 18/12/20.
//  Copyright © 2020 CupertinoKit. All rights reserved.
//

import Foundation

enum CPKOverlayStyleAppearance {
    case dark
    case white
}

protocol CPKOverlayStyleProtocol {
    var appearance: CPKOverlayStyleAppearance { get }
    var opacity: Double { get }
}
