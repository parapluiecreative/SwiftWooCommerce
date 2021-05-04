//
//  ATCInAppPurchaseManager.swift
//  DatingApp
//
//  Created by Duy Bui on 12/29/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import StoreKit

private let premiumIdentifier = "com.instaswipey.Premium"

public enum ATCPurchaseStatus {
    case success
    case failed(with: Error?)
}

enum ATCIAPError: Error {
    case unknown
}

final class ATCInAppPurchaseManager: NSObject, ATCInAppPurchaseProtocol {
    var completion: ((ATCPurchaseStatus) -> Void)?
    fileprivate var subscription: SKProduct?

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    func upgradeVIP() {
        if let subscription = subscription {
            purchaseProduct(product: subscription)
        } else {
            fetchAvailableProducts()
        }
    }

    var isVIPUpgraded: Bool {
        return UserDefaults.standard.bool(forKey: premiumIdentifier)
    }

    func fetchAvailableProducts() {
        if !isVIPUpgraded {
            let request = SKProductsRequest(productIdentifiers: Set([premiumIdentifier]))
            request.delegate = self
            request.start()
        }
    }
}

extension ATCInAppPurchaseManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        subscription = response.products.first { $0.productIdentifier == premiumIdentifier }
    }
    func request(_ request: SKRequest, didFailWithError error: Error) {
        completion?(.failed(with: nil))
    }
}

extension ATCInAppPurchaseManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        guard let premiumTransaction = transactions.filter({ $0.payment.productIdentifier == premiumIdentifier }).first else { return }
        switch premiumTransaction.transactionState {
        case .purchased, .restored:
            UserDefaults.standard.set(true, forKey: premiumIdentifier)
            SKPaymentQueue.default().finishTransaction(premiumTransaction)
            completion?(.success)
        case .failed:
            SKPaymentQueue.default().finishTransaction(premiumTransaction)
            completion?(.failed(with: premiumTransaction.error))
        case .deferred, .purchasing:
            completion?(.failed(with: nil))
            break
        default:
            break
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        completion?(.failed(with: error))
    }
}
