//
//  ATCImage.swift
//  ListingApp
//
//  Created by Florian Marcu on 6/10/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCImage: ATCGenericBaseModel {

    var urlString: String?
    var localImage: UIImage? = nil
    var isActionable: Bool = false
    var isVideoPreview: Bool {
        return (videoUrlString != nil)
    }
    var videoUrlString: String?

    convenience init(_ urlString: String? = nil, videoUrlString: String? = nil, placeholderImage: UIImage? = nil) {
        self.init(jsonDict: [:])
        self.urlString = urlString
        self.localImage = placeholderImage
        self.videoUrlString = videoUrlString
    }

    convenience init(localImage: UIImage) {
        self.init(jsonDict: [:])
        self.localImage = localImage
        self.urlString = nil
    }

    required init(jsonDict: [String: Any]) {}

    var description: String {
        return urlString ?? ""
    }
}
