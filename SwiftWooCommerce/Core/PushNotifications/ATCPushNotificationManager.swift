//
//  ATCPushNotificationManager.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/27/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications

class ATCPushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    let user: ATCUser
    
    init(user: ATCUser) {
        self.user = user
        super.init()
    }
    
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notifications sent on APNS
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _,_  in })
            // For iOS 10 data message sent by FCM
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        updateFirestorePushTokenIfNeeded()
    }
    
    func updateFirestorePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken, let uid = user.uid {
            let usersRef = Firestore.firestore().collection("users").document(uid)
            usersRef.setData(["pushToken": token], merge: true)
        }
    }
    
    func removeFirestorePushTokenIfNeeded() {
        if let uid = user.uid {
            let usersRef = Firestore.firestore().collection("users").document(uid)
            usersRef.updateData(["pushToken": FieldValue.delete()])
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        updateFirestorePushTokenIfNeeded()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        guard let notificationType = userInfo["notificationType"] as? String else { return }
        
        /// With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        DispatchQueue.main.async {
            if let notificationType = ATCNotificationType(rawValue: notificationType) {
                NotificationCenter.default.post(name: notificationType.notiticationName, object: nil, userInfo: userInfo)
            }
        }
    }
}
