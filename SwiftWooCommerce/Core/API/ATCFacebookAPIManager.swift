//
//  ATCFacebookAPIManager.swift
//  AppTemplatesCore
//
//  Created by Florian Marcu on 2/2/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.

import FBSDKCoreKit
import FBSDKLoginKit

let kGraphPathMe = "me"
let kGraphPathMePageLikes = "me/likes"

class ATCFacebookAPIManager {

    let accessToken: AccessToken
    let networkingManager = ATCNetworkingManager()

    init(accessToken: AccessToken) {
        self.accessToken = accessToken
    }

    func requestFacebookUser(completion: @escaping (_ facebookUser: ATCFacebookUser?) -> Void) {
        let graphRequest = GraphRequest(graphPath: kGraphPathMe, parameters: ["fields":"id,email,last_name,first_name,picture"], tokenString: accessToken.tokenString, version: nil, httpMethod: .get)
        graphRequest.start { (connection, result, error) in
            guard let result = result as? [String:String] else{
                print("Facebook request user error")
                return
            }
            completion(ATCFacebookUser(jsonDict: result))
        }
    }

    func requestFacebookUserPageLikes() {
        let graphRequest = GraphRequest(graphPath: kGraphPathMePageLikes, parameters: [:], tokenString: accessToken.tokenString, version: nil, httpMethod: .get)
        graphRequest.start { (connection, result, error) in
            print (result ?? "")
        }
    }

    func requestWallPosts(completion: @escaping (_ posts: [ATCFacebookPost]) -> Void) {
        let graphRequest = GraphRequest(graphPath: "me/posts", parameters: ["fields":"link,created_time,description,picture,name","limit":"500"], tokenString: accessToken.tokenString, version: nil, httpMethod: .get)

        graphRequest.start { (connection, result, error) in
            guard let result = result as? [String:String] else{
                print("Facebook request user error")
                completion([])
                return
            }
            self.processWallPostResponse(dictionary: result, posts: [], completion: completion)
        }
    }

    private func processWallPostResponse(dictionary: [String: Any?], posts: [ATCFacebookPost], completion: @escaping (_ posts: [ATCFacebookPost]) -> Void) {
        var newPosts = [ATCFacebookPost]()
        if let array = dictionary["data"] as? [[String: String]] {
            for dict in array {
                newPosts.append(ATCFacebookPost(jsonDict: dict))
            }
        }
        guard let paging = dictionary["paging"] as? [String: String], let next = paging["next"] as String?, next.count > 0 else {
            completion(posts + newPosts)
            return
        }
        networkingManager.get(path: next, params: [:], completion: { (jsonResponse, responseStatus) in
            switch responseStatus {
            case .success:
                guard let jsonResponse = jsonResponse, let dictionary = jsonResponse as? [String: Any] else {
                    completion(posts + newPosts)
                    return
                }
                self.processWallPostResponse(dictionary: dictionary, posts: posts + newPosts, completion: completion)
            case .error(_):
                completion(posts + newPosts)
            }
        })
    }
}
