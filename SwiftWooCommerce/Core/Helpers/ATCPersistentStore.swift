//
//  ATCPersistentStore.swift
//  DashboardApp
//
//  Created by Florian Marcu on 8/16/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCPersistentStore {
    
    private static let kWalkthroughCompletedKey = "kWalkthroughCompletedKey"
    private static let kLoggedInUserKey = "kUserKey"
    
    func markWalkthroughCompleted() {
        UserDefaults.standard.set(true, forKey: ATCPersistentStore.kWalkthroughCompletedKey)
    }
    
    func isWalkthroughCompleted() -> Bool {
        return UserDefaults.standard.bool(forKey: ATCPersistentStore.kWalkthroughCompletedKey)
    }
    
    func markUserAsLoggedIn(user: ATCUser) {
        do {
            let res = try NSKeyedArchiver.archivedData(withRootObject: user, requiringSecureCoding: false)
            UserDefaults.standard.set(res, forKey: ATCPersistentStore.kLoggedInUserKey)
        } catch {
            print("Couldn't save due to \(error)")
        }
    }
    
    func userIfLoggedInUser() -> ATCUser? {
        do {
            if let data = UserDefaults.standard.value(forKey: ATCPersistentStore.kLoggedInUserKey) as? Data,
                let user = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? ATCUser {
                return user
            }
            return nil
        } catch {
            print("Couldn't load due to \(error)")
            return nil
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: ATCPersistentStore.kLoggedInUserKey)
    }
}
