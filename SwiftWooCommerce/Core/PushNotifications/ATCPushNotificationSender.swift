//
//  ATCPushNotificationSender.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/27/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

let serverKey = "AAAAeliTfEs:APA91bGve5fyExjSiUCB0oI09Br1yGUSb0tPHelAk7L0FUytHWGOMlBPexJubTwSjjJTaIlK7oto3jDevoj9c5Q4Qalk6QEtQ9Y3tYfTxHD7OrmPZuVJjVGGciPBJXThG9QHCZQqx9Id"

class ATCPushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String) {
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body, "sound": "default"],
                                           "data" : ["user" : "test_id"]
        ]

        handlePushNotification(with: paramString)
    }
    
    func sendPushNotification(token: String, title: String, body: String, notificationType: ATCNotificationType, payload: [String: String]) {
        var data = payload
        data["notificationType"] = notificationType.rawValue
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body, "sound": "default"],
                                           "data" : data
        ]
        handlePushNotification(with: paramString)
    }
    
    private func handlePushNotification(with params: [String : Any]) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=" + serverKey, forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
