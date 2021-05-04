//
//  ATCFirebaseLoginManager.swift
//  AppTemplatesFoundation
//
//  Created by Florian Marcu on 2/6/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore

public class ATCFirebaseLoginManager {
    let userManager: ATCSocialUserManagerProtocol?
    
    init(userManager: ATCSocialUserManagerProtocol?) {
        self.userManager = userManager
    }

    static func login(credential: AuthCredential, completionBlock: @escaping (_ user: ATCUser?) -> Void) {
        Auth.auth().signIn(with: credential) { (authResult, error) in
            completionBlock(ATCFirebaseLoginManager.atcUser(for: authResult?.user))
        }
    }

    static func signIn(email: String, pass: String, completionBlock: @escaping (_ user: ATCUser?, _ errorMessage: String?) -> Void) {
        let trimmedEmail = email.atcTrimmed()
        let trimmedPass = pass.atcTrimmed()
        
        Auth.auth().signIn(withEmail: trimmedEmail, password: trimmedPass) { (result, error) in
            if let error = error, let errCode = AuthErrorCode(rawValue: error._code) {
                switch errCode {
                    case .userNotFound:
                        Auth.auth().createUser(withEmail: trimmedEmail, password: trimmedPass) { (user, error) in
                            if error == nil {
                                ATCFirebaseLoginManager.signIn(email: trimmedEmail, pass: trimmedPass, completionBlock: completionBlock)
                            }
                    }
                    case .wrongPassword:
                        completionBlock(nil, "E-mail already exists. Did you sign up with a different method (email, facebook, apple)?".localizedCore)
                        return
                    default:
                        return
                }
            } else {
                completionBlock(ATCFirebaseLoginManager.atcUser(for: result?.user), nil)
            }
        }
    }

    static func atcUser(for firebaseUser: User?) -> ATCUser? {
        guard let fUser = firebaseUser else { return nil }
        return ATCUser(uid: fUser.uid,
                       firstName: fUser.displayName ?? "",
                       lastName: "",
                       avatarURL: fUser.providerData[0].photoURL?.absoluteString ?? "",
                       email: fUser.email ?? "")
    }

    func saveUserToServerIfNeeded(user: ATCUser, appIdentifier: String) {
        let ref = Firestore.firestore().collection("users")
        if let uid = user.uid {
            var dict = user.representation
            dict["appIdentifier"] = appIdentifier
            ref.document(uid).setData(dict, merge: true)
        }
    }

    func resyncPersistentUser(user: ATCUser, completionBlock: @escaping (_ user: ATCUser?, _ error: Error?) -> Void) {
        if let uid = user.uid {
            self.userManager?.fetchUser(userID: uid) { (newUser, error) in
                if let newUser = newUser {
                    completionBlock(newUser, error)
                } else {
                    // User is no longer existing
                    if let email = user.email, user.uid == email {
                        // We don't log out Apple Signed in users
                        completionBlock(user, error)
                        return
                    }
                    NotificationCenter.default.post(name: kLogoutNotificationName, object: nil)
                }
            }
        }
    }
}
