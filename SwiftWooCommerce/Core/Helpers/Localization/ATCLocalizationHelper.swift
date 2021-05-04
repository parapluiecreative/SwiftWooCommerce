//
//  ATCLocalizationHelper.swift
//  StoreLocator
//
//  Created by Duy Bui on 12/4/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Foundation

class ATCLocalizationHelper {
    static var isRTLLanguage: Bool {
        return NSLocale.characterDirection(forLanguage: NSLocale.current.languageCode ?? "") == .rightToLeft
    }
}

extension String {
    
    private func localize(in file: String) -> String {
        if let language = NSLocale.current.languageCode, language == "en" {
            return self
        } else {
            return NSLocalizedString(self, tableName: file, bundle: Bundle.main, value: "", comment: "")
        }
    }
    
    /// Localization Language (common)
    var localizedCore: String {
        return localize(in: "ATCLocalizableCommon")
    }
    
    /// Localization In App
    var localizedInApp: String {
        return localize(in: "Localizable")
    }
    
    // MARK: - Localization for each part
    var localizedReviews: String {
        return localize(in: "ATCLocalizableReviews")
    }
    
    var localizedChat: String {
        return localize(in: "ATCChatLocalizable")
    }
    
    var localizedComposer: String {
        return localize(in: "ATCComposerLocalizable")
    }
    
    var localizedModels: String {
        return localize(in: "ATCModelsLocalizable")
    }
    
    var localizedListing: String {
        return localize(in: "ATCListingLocalizable")
    }
    
    var localizedThirdParty: String {
        return localize(in: "ATCThirdPartyLocalizable")
    }
    
    var localizedEcommerce: String {
        return localize(in: "ATCEcommerceLocalizable")
    }
    
    var localizedFeed: String {
        return localize(in: "ATCFeedLocalizable")
    }
    
    var localizedSettings: String {
        return localize(in: "ATCSettingsLocalizable")
    }
    
    var localizedDriver: String {
        return localize(in: "ATCDriverLocalizable")
    }
}
