//
//  ATCInAppPurchaseProtocol.swift
//  DatingApp
//
//  Created by Duy Bui on 12/29/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import StoreKit

public protocol ATCInAppPurchasable {
    var canMakePayments: Bool { get }
    func purchaseProduct(product: SKProduct)
    func restoreCompletedTransactions()
    func fetchAvailableProducts()
}

public protocol ATCVIPUpgradable {
    func upgradeVIP()
    var isVIPUpgraded: Bool { get }
}

protocol ATCInAppPurchaseProtocol: ATCInAppPurchasable, ATCVIPUpgradable { }

extension ATCInAppPurchaseProtocol {
    var canMakePayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func purchaseProduct(product: SKProduct) {
        SKPaymentQueue.default().add(SKPayment(product: product))
    }
    
    func restoreCompletedTransactions() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
