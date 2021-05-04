//
//  FirebasePlaceOrderManager.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/23/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import FirebaseFirestore

class ATCFirebasePlaceOrderManager: ATCPlaceOrderManagerProtocol, ATCAllAdminsFirebaseDataSourceProtocol {
    var tableName: String

    init(tableName: String) {
        self.tableName = tableName
    }

    func placeOrder(user: ATCUser?,
                    address: ATCAddress?,
                    cart: ATCShoppingCart,
                    completion: @escaping (_ success: Bool) -> Void) {
        let firebaseWriter = ATCFirebaseFirestoreWriter(tableName: tableName)
        var representation = cart.representation()
        if let user = user {
            representation["user_id"] = user.uid
            representation["user"] = user.representation
            representation["authorID"] = user.uid
            representation["author"] = user.representation
        }
        if let address = address {
            representation["address"] = address.representation
        }
        representation["createdAt"] = Date()
        representation["status"] = "Order Placed"
        firebaseWriter.save(representation) { [weak self] in
            /// When an order status has been placed, we will send a notification to all admins
            self?.sendNotificationsToAllAdmins()
            completion(true)
        }
    }

    func updateOrder(order: ATCOrder,
                     newStatus: String,
                     completion: ((_ success: Bool) -> Void)?) {
        let data: [String: Any] = ["status": newStatus]
        Firestore
            .firestore()
            .collection(self.tableName)
            .document(order.id)
            .setData(data, merge: true, completion: { (error) in
                /// When an order status has been updated, we will send to that customer
                /// Also, it helps function still gets call while self gets detroyed but don't retain cycle
                DispatchQueue.global(qos: .utility).async {
                    self.sendPushNotificationUponOrderStatusChange(order, newStatus: newStatus)
                }
                completion?(error == nil)
            })
    }
    
    // MARK: Helper notification functions
    private func sendNotificationsToAllAdmins() {
        /// Put sending notification into another queue to avoid making the Main thread slow down
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.fetchAllAdmins { (admins) in
                let notificationSender = ATCPushNotificationSender()
                admins.forEach { (admin) in
                    if let token = admin.pushToken {
                        notificationSender.sendPushNotification(to: token,
                                                                title: "Restaurant".localizedEcommerce,
                                                                body: "New order has been placed".localizedEcommerce)
                    }
                }
            }
        }
    }
    
    private func sendPushNotificationUponOrderStatusChange(_ order: ATCOrder, newStatus: String) {
        /// Put sending notification into another queue to avoid making the Main thread slow down
        let notificationSender = ATCPushNotificationSender()
        if let token = order.customer?.pushToken, let orderStatus = ATCOrderStatus(rawValue: newStatus) {
            notificationSender.sendPushNotification(to: token,
                                                    title: "Restaurant".localizedEcommerce,
                                                    body: orderStatus.notificationDescription)
        }
    }
}
