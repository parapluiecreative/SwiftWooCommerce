//
//  ATCFormImageViewModel.swift
//  ListingApp
//
//  Created by Florian Marcu on 10/6/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCFormImageViewModel: ATCGenericBaseModel {
    var image: UIImage? = nil
    var isVideoPreview: Bool {
        return (videoUrl != nil)
    }
    var videoUrl: URL? = nil
    var description: String {
        return "ATCFormImageViewModel"
    }

    init(image: UIImage?, videoUrl: URL? = nil) {
        self.image = image
        self.videoUrl = videoUrl
    }

    required init(jsonDict: [String : Any]) {
        fatalError()
    }
}
