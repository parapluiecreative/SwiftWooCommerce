//
//  ATCGenericRestAPIDataSource.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 10/22/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

struct ATCGenericRestAPIDataSourceConfiguration {
    let loadFirstURLString: String
    let loadTopURLString: String
    let consumerKey: String?
    let consumerSecret: String?
    let computeLoadBottomURLString: (_ page: UInt) -> String
}

class ATCGenericRestAPIDataSource<T: ATCGenericBaseModel> {
    weak var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?
    private var store: [T] = [T]()
    private var apiManager = ATCAPIManager()
    private var currentPage: UInt = 0
    private var configuration: ATCGenericRestAPIDataSourceConfiguration
    fileprivate var bottomStreamLoadingEnded = false
    fileprivate var isLoadingBottom = false
    fileprivate var isLoadingTop = false

    init(configuration: ATCGenericRestAPIDataSourceConfiguration) {
        self.configuration = configuration
    }

    fileprivate func findStreamObject(object: T) -> Bool {
        return store.filter({object.description == $0.description}).count > 0
    }
}

extension ATCGenericRestAPIDataSource: ATCGenericCollectionViewControllerDataSource {
    func object(at index: Int) -> ATCGenericBaseModel? {
        if (index < store.count) {
            return store[index]
        }
        return nil
    }

    func numberOfObjects() -> Int {
        return store.count
    }

    func loadFirst() {
        apiManager.retrieveListFromJSON(urlPath: configuration.loadFirstURLString, parameters: requestParameters(), completion: { (objects : [T]?, status) in
            switch(status) {
            case .success:
                self.currentPage = 1
                var results: [T] = []
                objects?.forEach({
                    if !self.findStreamObject(object: $0) {
                        self.store += [$0]
                        results += [$0]
                    }
                })
                if ((objects?.count ?? 0) == 0) {
                    self.bottomStreamLoadingEnded = true
                }
                self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: results)
            case .error:
                break
            }
        })
    }

    func loadBottom() {
        if (isLoadingBottom || bottomStreamLoadingEnded) {
            return
        }
        isLoadingBottom = true
        apiManager.retrieveListFromJSON(urlPath: configuration.computeLoadBottomURLString(self.currentPage), parameters: requestParameters(), completion: { (objects : [T]?, status) in
            switch(status) {
            case .success:
                self.currentPage += 1
                var results: [T] = []
                objects?.forEach({
                    if !self.findStreamObject(object: $0) {
                        self.store += [$0]
                        results += [$0]
                    }
                })
                if ((objects?.count ?? 0) == 0) {
                    self.bottomStreamLoadingEnded = true
                }
                self.isLoadingBottom = false
                self.delegate?.genericCollectionViewControllerDataSource(self, didLoadBottom: results)
            case .error:
                break
            }
        })
    }

    func loadTop() {
        if (isLoadingTop) {
            return
        }
        isLoadingTop = true
        apiManager.retrieveListFromJSON(urlPath: configuration.loadTopURLString, parameters: requestParameters(), completion: { (objects : [T]?, status) in
            switch(status) {
            case .success:
                var results: [T] = []
                objects?.forEach({
                    if !self.findStreamObject(object: $0) {
                        self.store += [$0]
                        results += [$0]
                    }
                })
                self.isLoadingTop = false
                self.delegate?.genericCollectionViewControllerDataSource(self, didLoadTop: results)
            case .error:
                break
            }
        })
    }

    private func requestParameters() -> [String: String] {
        if let consumerKey = configuration.consumerKey, let consumerSecret = configuration.consumerSecret {
            return [
                "consumer_key": consumerKey,
                "consumer_secret": consumerSecret
            ]
        }
        return [:]
    }
}
