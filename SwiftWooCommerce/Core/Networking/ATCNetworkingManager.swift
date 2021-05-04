//
//  ATCNetworkingManager.swift
//  AppTemplatesCore
//
//  Created by Florian Marcu on 2/2/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import Alamofire

public enum ATCNetworkResponseStatus {
    case success
    case error(string: String?)
}

public class ATCNetworkingManager {

    let queue = DispatchQueue(label: "networking-manager-requests", qos: .userInitiated, attributes: .concurrent)

    func getJSONResponse(path: String, parameters: [String:String]?, completionHandler: @escaping (_ response: Any?,_ status: ATCNetworkResponseStatus) -> Void) {
        AF.request(path, method: .get, parameters: parameters)
            .responseJSON(queue: queue, options: []) { (response) in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let value):
                    completionHandler(value, .success)
                case .failure(let error):
                    print(error)
                    completionHandler(nil, .error(string: error.localizedDescription))
                }
            }
        }
    }

    func get(path: String, params: [String:String]?, completion: @escaping ((_ jsonResponse: Any?, _ responseStatus: ATCNetworkResponseStatus) -> Void)) {
        AF.request(path, parameters: params).responseJSON { response in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let value):
                    completion(value, .success)
                case .failure(let error):
                    print(error)
                    completion(nil, .error(string: error.localizedDescription))
                }
            }
        }
    }

}
