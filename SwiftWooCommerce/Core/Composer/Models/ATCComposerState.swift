//
//  ATCComposerState.swift
//  ListingApp
//
//  Created by Florian Marcu on 10/6/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCComposerState {
    var title: String? = nil
    var description: String? = nil
    var price: String? = nil
    var images: [UIImage]? = []
    var longitude: Double? = nil
    var latitude: Double? = nil
    var location: String? = nil
    var category: ATCListingCategory? = nil
    var filters: [ATCSelectFilter]? = nil
}
