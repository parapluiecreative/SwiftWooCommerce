//
//  CPKOverlayedImageViewStyleProtocol.swift
//  CupertinoKit
//
//  Created by Mayil Kannan on 22/12/20.
//  Copyright © 2020 CupertinoKit. All rights reserved.
//

import Foundation

enum CPKOverlayedImageViewStyleAppearance {
    case dark
    case white
}

protocol CPKOverlayedImageViewStyleProtocol {
    var imageAppearance: CPKOverlayedImageViewStyleAppearance { get }
    var imageOpacity: Double { get }
}
