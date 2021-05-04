//
//  ATCOrderStatus.swift
//  RestaurantApp
//
//  Created by Duy Bui on 6/5/20.
//  Copyright © 2020 iOS App Templates. All rights reserved.
//

import Foundation

enum ATCOrderStatus: String, CaseIterable {
    case orderPlaced = "Order Placed"
    case orderAccepted = "Order Accepted"
    case orderRejected = "Order Rejected"
    case driverPending = "Driver Pending"
    case driverAccepted = "Driver Accepted"
    case driverRejected = "Driver Rejected"
    case orderShipped = "Order Shipped"
    case inTransit = "In transit"
    case orderCompleted = "Order Completed"
    case orderCancelled = "Order Cancelled"
    
    var status: String {
        return self.rawValue.localizedEcommerce
    }
    
    var notificationDescription: String {
        switch self {
        case .orderPlaced:
            return "Your order has been placed".localizedEcommerce
        case .orderShipped:
            return "Your order has been shipped".localizedEcommerce
        case .inTransit:
            return "Your order is in transit".localizedEcommerce
        case .orderCompleted:
            return "Your order has been completed".localizedEcommerce
        case .orderCancelled:
            return "Your order has been cancelled".localizedEcommerce
        case .orderAccepted:
            return "Your order has been accepted".localizedEcommerce
        case .orderRejected:
            return "Your order has been rejected".localizedEcommerce
        case .driverPending:
            return "Your order has been waiting for driver".localizedEcommerce
        case .driverAccepted:
            return "Your order has been accepted by driver".localizedEcommerce
        case .driverRejected:
            return "Your order has been rejected by driver".localizedEcommerce
        }
    }
    
    func checkSelectedItem(by value: String) -> Bool {
        return self.status == value
    }
}
