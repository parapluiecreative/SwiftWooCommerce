//
//  ATCRSSItemBaseModel.swift
//  NewsReader
//
//  Created by Florian Marcu on 3/26/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import AlamofireRSSParser
import UIKit

public protocol ATCRSSItemBaseModel {
    init(rssItem: RSSItem)
}
