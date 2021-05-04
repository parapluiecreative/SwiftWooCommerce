//
//  ATCPlacingOrderViewController.swift
//  MultiVendorApp
//
//  Created by Mac  on 26/04/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit

protocol PlacingOrderViewProtocol {
    func didFinishLoading()
}

class ATCPlacingOrderViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var address1: UILabel!
    @IBOutlet var address2: UILabel!
    @IBOutlet var userName: UILabel!
    @IBOutlet weak var foodItemsTableView: UITableView!
    @IBOutlet weak var progressBar: ATCCircularProgressBar!

    let uiConfig: ATCUIGenericConfigurationProtocol
    let cartManager: ATCShoppingCartManager
    let address: ATCAddress

    var delegate: PlacingOrderViewProtocol? = nil
    
    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         uiConfig: ATCUIGenericConfigurationProtocol,
         cartManager: ATCShoppingCartManager,
         address: ATCAddress) {
        self.uiConfig = uiConfig
        self.cartManager = cartManager
        self.address = address
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "Placing order...".localizedEcommerce
        titleLabel.font = uiConfig.boldFont(size: 26)
        titleLabel.textColor = UIColor.darkGray.darkModed

        address1.font = uiConfig.regularFont(size: 18)
        address1.textColor = UIColor.darkGray.darkModed

        address2.font = uiConfig.lightFont(size: 13)
        address2.textColor = UIColor.lightGray.darkModed

        userName.font = uiConfig.boldFont(size: 15)
        userName.textColor = UIColor.darkGray.darkModed

        address1.text = address.fullAddress
        address2.text = "Deliver to door"
        userName.text = "Your order, " + (address.name ?? "")
        
        foodItemsTableView.register(UINib(nibName: "ATCPlacingOrderFoodItemsTableViewCell", bundle: nil), forCellReuseIdentifier: "ATCPlacingOrderFoodItemsTableViewCell")
        
        progressBar.safePercent = 100
        progressBar.lineColor = .blue
        progressBar.lineBackgroundColor = .white
        progressBar.lineFinishColor = .blue
        progressBar.labelSize = 0
        progressBar.lineWidth = 3
        
        self.isModalInPresentation = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        progressBar.setProgress(to: 1, withAnimation: true) {
            self.dismiss(animated: true, completion: nil)
            self.delegate?.didFinishLoading()
        }
    }
}

extension ATCPlacingOrderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartManager.numberOfObjects()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ATCPlacingOrderFoodItemsTableViewCell", for: indexPath) as? ATCPlacingOrderFoodItemsTableViewCell else { return UITableViewCell() }
        let item = cartManager.object(at: indexPath.row)
        cell.configure(item: item, uiConfig: uiConfig)
        return cell
    }
}
