//
//  ATCGenericSearchViewController.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 5/20/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit

typealias ATCGenericSearchViewControllerCancelBlock = () -> Void

protocol ATCGenericSearchable: class {
    func matches(keyword: String) -> Bool
}

struct ATCGenericSearchViewControllerConfiguration {
    let searchBarPlaceholderText: String?
    let uiConfig: ATCUIGenericConfigurationProtocol
    let cellPadding: CGFloat
}

protocol ATCGenericSearchViewControllerDataSource: class {
    var viewer: ATCUser? {get set}
    var delegate: ATCGenericSearchViewControllerDataSourceDelegate? {get set}
    func search(text: String?)
    func update(completion: @escaping () -> Void)
}

protocol ATCGenericSearchViewControllerDataSourceDelegate: class {
    func dataSource(_ dataSource: ATCGenericSearchViewControllerDataSource, didFetchResults results: [ATCGenericBaseModel])
}

class ATCGenericSearchViewController<T: ATCGenericBaseModel>: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate, ATCGenericSearchViewControllerDataSourceDelegate{
 
    let searchController: UISearchController
    let configuration: ATCGenericSearchViewControllerConfiguration
    let searchResultsController: ATCGenericCollectionViewController
    let localDataSource: ATCGenericLocalDataSource<T>
    var cancelBlock: ATCGenericSearchViewControllerCancelBlock?

    var searchDataSource: ATCGenericSearchViewControllerDataSource? {
        didSet {
            searchDataSource?.delegate = self
        }
    }

    init(configuration: ATCGenericSearchViewControllerConfiguration) {
        let config = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                     pullToRefreshTintColor: configuration.uiConfig.mainThemeBackgroundColor,
                                                                     collectionViewBackgroundColor: configuration.uiConfig.mainThemeBackgroundColor,
                                                                     collectionViewLayout: ATCLiquidCollectionViewLayout(cellPadding: configuration.cellPadding),
                                                                     collectionPagingEnabled: false,
                                                                     hideScrollIndicators: true,
                                                                     hidesNavigationBar: false,
                                                                     headerNibName: nil,
                                                                     scrollEnabled: true,
                                                                     uiConfig: configuration.uiConfig,
                                                                     emptyViewModel: nil)
        localDataSource = ATCGenericLocalDataSource<T>(items: [])
        searchResultsController = ATCGenericCollectionViewController(configuration: config)
        searchResultsController.genericDataSource = localDataSource
        
        searchController = UISearchController(searchResultsController: searchResultsController)
        self.configuration = configuration

        super.init(nibName: nil, bundle: nil)

        searchController.delegate = self
        searchController.searchResultsUpdater = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchBar.placeholder = configuration.searchBarPlaceholderText
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.delegate = self
        searchController.view.backgroundColor = configuration.uiConfig.mainThemeBackgroundColor
        self.navigationItem.titleView = searchController.searchBar
        self.definesPresentationContext = true
        searchDataSource?.search(text: "")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async { [weak self] in
            self?.searchController.searchBar.becomeFirstResponder()
         }
    }

    func use(adapter: ATCGenericCollectionRowAdapter, for classString: String) {
        searchResultsController.use(adapter: adapter, for: classString)
    }

    func updateSearchResults(for searchController: UISearchController) {
        searchDataSource?.search(text: searchController.searchBar.text)
    }

    func dataSource(_ dataSource: ATCGenericSearchViewControllerDataSource, didFetchResults results: [ATCGenericBaseModel]) {
        if let res = results as? [T] {
            localDataSource.update(items: res)
        }
    }

    // MARK: - UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if let cancelBlock = cancelBlock {
            cancelBlock()
        }
    }
}

class ATCGenericLocalSearchDataSource: ATCGenericSearchViewControllerDataSource {

    var viewer: ATCUser? = nil
    let items: [ATCGenericBaseModel]
    weak var delegate: ATCGenericSearchViewControllerDataSourceDelegate?

    init(items: [ATCGenericBaseModel]) {
        self.items = items
    }

    func search(text: String?) {
        delegate?.dataSource(self, didFetchResults: items.shuffled())
    }

    func update(completion: @escaping () -> Void) {}
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }

        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
