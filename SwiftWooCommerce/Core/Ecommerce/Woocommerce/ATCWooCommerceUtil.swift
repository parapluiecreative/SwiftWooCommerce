//
//  ATCWooCommerceUtil.swift
//  Shopertino
//
//  Created by Florian Marcu on 6/23/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit

class ATCWooCommerceUtil {

    static func metadataValue(for key: String, metaData: [[String: Any]]) -> String? {
        for itemDict in metaData {
            for (currentKey, value) in itemDict {
                if (currentKey == "key") {
                    if let value = value as? String {
                        if key == value {
                            return itemDict["value"] as? String
                        }
                    }
                }
            }
        }
        return nil
    }
}
