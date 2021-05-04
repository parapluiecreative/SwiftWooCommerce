//
//  ATCApplePayManager.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 6/26/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import PassKit

class ATCApplePayManager: NSObject {
    let currencyCode: String
    let countryCode: String
    let merchantID: String
    let paymentNetworks: [PKPaymentNetwork]
    let items: [PKPaymentSummaryItem]

    init(
        items: [PKPaymentSummaryItem],
        currencyCode: String = "USD",
        countryCode: String = "US",
        merchantID: String = "merchant.com.iosapptemplates",
        paymentNetworks: [PKPaymentNetwork] = [PKPaymentNetwork.amex, PKPaymentNetwork.masterCard, PKPaymentNetwork.visa]) {
        self.items = items
        self.currencyCode = currencyCode
        self.countryCode = countryCode
        self.merchantID = merchantID
        self.paymentNetworks = paymentNetworks
    }

    func paymentViewController() -> PKPaymentAuthorizationViewController? {
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
            let request = PKPaymentRequest()
            request.currencyCode = self.currencyCode
            request.countryCode = self.countryCode
            request.supportedNetworks = self.paymentNetworks
            request.merchantIdentifier = self.merchantID
            request.paymentSummaryItems = items
            request.shippingType = .shipping
            request.requiredBillingAddressFields = [.email, .name, .postalAddress]
            request.requiredShippingContactFields = [.name, .postalAddress, .phoneNumber]

            request.merchantCapabilities = .capability3DS
            return PKPaymentAuthorizationViewController(paymentRequest: request)
        }
        return nil
    }
}
