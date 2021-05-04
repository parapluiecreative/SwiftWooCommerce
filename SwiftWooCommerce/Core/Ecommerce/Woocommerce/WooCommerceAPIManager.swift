//
//  WooCommerceAPIManager.swift
//  Shopertino
//
//  Created by Florian Marcu on 9/3/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class WooCommerceAPIManager {

    let baseURL: String
    let key: String
    let secret: String

    let productCategoriesEndpoint = "wp-json/wc/v2/products/categories"
    let productsEndpoint = "/wp-json/wc/v2/products"
    let ordersEndpoint = "/wp-json/wc/v2/orders"

    init(baseURL: String, key: String, secret: String) {
        self.baseURL = baseURL
        self.key = key
        self.secret = secret
    }

    func fetchProducts(categoryId: String? = nil, completion: @escaping ([Product]?) -> Void) -> URLSessionDataTask? {
        var urlString = baseURL + productsEndpoint
        if let categoryId = categoryId {
            urlString += "?category=" + categoryId
        }
        if let url = NSURL(string: urlString) as? URL {
            let task = self.request(url: url) { (responseDict) in
                if let jsonList = responseDict as? [[String: AnyObject]] {
                    var products: [Product] = []
                    for dict in jsonList {
                        let product = Product(wooCommerceDict: dict)
                        products.append(product)
                    }
                    completion(products)
                } else {
                    completion(nil)
                }
            }
            return task
        }

        return nil
    }

    func fetchCategories(completion: @escaping ([[String: AnyObject]]?) -> Void) {
        let urlString = baseURL + productCategoriesEndpoint
        if let url = NSURL(string: urlString) as? URL {
            self.request(url: url) { (responseDict) in
                if let response = responseDict as? [[String: AnyObject]] {
                    completion(response)
                } else {
                    completion(nil)
                }
            }
        }
    }

    func fetchOrders(email: String, completion: @escaping ([[String: AnyObject]]?) -> Void) {
        let urlString = baseURL + ordersEndpoint
        if let url = NSURL(string: urlString) as? URL {
            self.request(url: url) { (responseDict) in
                if let response = responseDict as? [[String: AnyObject]] {
                    completion(response)
                } else {
                    completion(nil)
                }
            }
        }
    }

    private func request(url: URL, completion: @escaping (AnyObject?) -> Void) -> URLSessionDataTask {
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let loginString = String(format: "%@:%@", key, secret)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? AnyObject {
                        DispatchQueue.main.async {
                            completion(jsonDataDict)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
                completion(nil)
            }
        }
        task.resume()
        return task
    }

    private func submit(url: URL, params:[String: Any], completion: @escaping (AnyObject?) -> Void) {
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [.prettyPrinted])
        let loginString = String(format: "%@:%@", key, secret)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? AnyObject {
                        DispatchQueue.main.async {
                            completion(jsonDataDict)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
}

extension WooCommerceAPIManager: ATCPlaceOrderManagerProtocol {
    func placeOrder(user: ATCUser?, address: ATCAddress?, cart: ATCShoppingCart, completion: @escaping (_ success: Bool) -> Void) {
        var lineItems: [[String: Any]] = []
        for item in cart.distinctProductItems() {
            let lineItem: [String: Any] = ["product_id": item.product.cartId,
                                           "quantity": item.quantity,
                                           "meta_data": [["key": "color",
                                                          "value": item.selectedColor ?? "no color"],
                                                         ["key": "size",
                                                          "value": item.selectedSize ?? "no size"],
                                                         ["key": "imageURLString",
                                                          "value": item.product.cartImageURLString],
                                                         ["key": "email",
                                                          "value": user?.email ?? ""],
                                                         ["key": "uid",
                                                          "value": user?.uid ?? ""]
                ]
            ]
            lineItems.append(lineItem)
        }

        var addressDict = [String: Any]()
        if let address = address {
            addressDict["first_name"] = user?.firstName
            addressDict["last_name"] = user?.lastName
            addressDict["address_1"] = address.line1
            addressDict["address_2"] = address.line2
            addressDict["city"] = address.city
            addressDict["state"] = address.state
            addressDict["postcode"] = address.postalCode
            addressDict["country"] = address.country
        }
        addressDict["email"] = user?.email

        let params: [String: Any] = [
            "set_paid": true,
            "payment_method": "stripe-mobile",
            "line_items": lineItems,
            "shipping": addressDict,
            "billing": addressDict
        ]
        let urlString = baseURL + ordersEndpoint
        if let url = NSURL(string: urlString) as? URL {
            self.submit(url: url,
                        params: params) { (result) in
                            print(result)
                            completion(true)
            }
        }
    }

    func updateOrder(order: ATCOrder, newStatus: String, completion: ((Bool) -> Void)?) {
        // TODO: Update order status in WooCommerce dashboard
    }
}
