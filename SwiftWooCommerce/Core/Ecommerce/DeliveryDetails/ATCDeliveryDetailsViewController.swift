//
//  ATCDeliveryDetailsViewController.swift
//  MultiVendorApp
//
//  Created by Mac  on 08/06/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit

class ATCDeliveryDetailsViewController: UIViewController {
    
    @IBOutlet weak var driverDetailsView: UIView!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var driverCodeLabel: UILabel!
    @IBOutlet weak var driverCarImageView: UIImageView!
    @IBOutlet weak var driverImageView: UIImageView!
    @IBOutlet weak var callImageView: UIImageView!
    @IBOutlet weak var sendMessageTextField: UITextField!
    @IBOutlet weak var deliveryDetailsLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var userAddressLabel: UILabel!
    @IBOutlet weak var deliveryTypeLabel: UILabel!
    @IBOutlet weak var orderDeliveryTypeLabel: UILabel!
    @IBOutlet weak var orderSummaryLabel: UILabel!
    @IBOutlet weak var orderTintLabel: UILabel!
    @IBOutlet weak var foodItemsCollectionView: UICollectionView!
    @IBOutlet weak var foodItemsCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var showMoreView: UIView!
    @IBOutlet weak var showMoreLabel: UILabel!
    @IBOutlet weak var dropDownImageView: UIImageView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var goldImageView: UIImageView!
    @IBOutlet weak var goldLabel: UILabel!
    @IBOutlet weak var nextRewardLabel: UILabel!
    @IBOutlet weak var rewardImageView: UIImageView!
    @IBOutlet weak var deliveryTypeSeparator: UILabel!
    @IBOutlet weak var addressSeparator: UILabel!
    @IBOutlet weak var totalSeparator: UILabel!
    
    let uiConfig: ATCUIGenericConfigurationProtocol
    let cartManager: ATCShoppingCartManager
    let order: ATCOrder
    var user: ATCUser?
    
    fileprivate let kCellReuseIdentifier = "CartItemCollectionViewCell"
    fileprivate let cartScreenCellHeight: CGFloat = 30
    fileprivate let defaultNumberOfCartsNeedToShow = 2

    var isShowMoreCartEnable = false
    
    var orderTrackingData: ATCOrder?
    let chatServerConfig = ChatServiceConfig()

    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         uiConfig: ATCUIGenericConfigurationProtocol,
         cartManager: ATCShoppingCartManager? = nil,
         orderTrackingData: ATCOrder?,
         order: ATCOrder,
         user: ATCUser?) {
        self.uiConfig = uiConfig
        self.cartManager = cartManager ?? ATCShoppingCartManager(cart: ATCShoppingCart())
        self.orderTrackingData = orderTrackingData
        self.order = order
        self.user = user
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        driverNameLabel.textColor = UIColor.gray.darkModed
        driverNameLabel.font = uiConfig.regularFont(size: 16)

        driverCodeLabel.textColor = UIColor.darkGray.darkModed
        driverCodeLabel.font = uiConfig.boldFont(size: 17)

        sendMessageTextField.textColor = uiConfig.mainTextColor
        sendMessageTextField.font = uiConfig.regularFont(size: 15)
        sendMessageTextField.layer.cornerRadius = sendMessageTextField.frame.height / 2

        deliveryDetailsLabel.textColor = UIColor.darkGray.darkModed
        deliveryDetailsLabel.font = uiConfig.boldFont(size: 20)
        deliveryDetailsLabel.text = "Delivery Details"

        addressLabel.textColor = UIColor.gray.darkModed
        addressLabel.font = uiConfig.regularFont(size: 14)

        userAddressLabel.textColor = UIColor.gray.darkModed
        userAddressLabel.font = uiConfig.regularFont(size: 16)

        deliveryTypeLabel.textColor = UIColor.gray.darkModed
        deliveryTypeLabel.font = uiConfig.regularFont(size: 14)

        orderDeliveryTypeLabel.textColor = UIColor.gray.darkModed
        orderDeliveryTypeLabel.font = uiConfig.regularFont(size: 16)

        orderSummaryLabel.textColor = UIColor.darkGray.darkModed
        orderSummaryLabel.font = uiConfig.boldFont(size: 20)

        orderTintLabel.textColor = uiConfig.mainSubtextColor
        orderTintLabel.font = uiConfig.regularFont(size: 15)

        showMoreLabel.textColor = uiConfig.mainSubtextColor
        showMoreLabel.font = uiConfig.regularFont(size: 15)

        totalLabel.textColor = UIColor.gray.darkModed
        totalLabel.font = uiConfig.regularFont(size: 17)

        totalValueLabel.textColor = UIColor.gray.darkModed
        totalValueLabel.font = uiConfig.regularFont(size: 18)

        goldLabel.textColor = uiConfig.mainTextColor
        goldLabel.font = uiConfig.regularFont(size: 15)

        nextRewardLabel.textColor = uiConfig.mainSubtextColor
        nextRewardLabel.font = uiConfig.regularFont(size: 15)
        
        addressSeparator.backgroundColor = UIColor.darkModeColor(hexString: "#EAEAEA")
        deliveryTypeSeparator.backgroundColor = UIColor.darkModeColor(hexString: "#EAEAEA")
        totalSeparator.backgroundColor = UIColor.darkModeColor(hexString: "#EAEAEA")
        sendMessageTextField.backgroundColor = UIColor.darkModeColor(hexString: "#F4F5F4")

        if let totalPrice = order.totalPrice() {
            totalValueLabel.text = "$".localizedEcommerce + totalPrice.twoDecimalsString()
        } else {
            totalValueLabel.text = ""
        }
        
        foodItemsCollectionView.delegate = self
        foodItemsCollectionView.dataSource = self
        
        foodItemsCollectionView.backgroundColor = uiConfig.mainThemeBackgroundColor
        foodItemsCollectionView.register(UINib(nibName: kCellReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: kCellReuseIdentifier)
        
        if cartManager.numberOfObjects() > defaultNumberOfCartsNeedToShow {
            showMoreView.isHidden = false
            foodItemsCollectionViewHeightConstraint.constant = cartScreenCellHeight * CGFloat(defaultNumberOfCartsNeedToShow) + CGFloat(cartManager.numberOfObjects() * 5)
        } else {
            showMoreView.isHidden = true
            foodItemsCollectionViewHeightConstraint.constant = cartScreenCellHeight * CGFloat(cartManager.numberOfObjects()) + CGFloat(cartManager.numberOfObjects() * 5)
        }
        
        self.updateDriverInfo(orderTrackingData: self.orderTrackingData)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didOrderComplete), name: kOrderCompleteNotificationName, object: nil)
    }
    
    @objc private func didOrderComplete() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateDriverInfo(orderTrackingData: ATCOrder?) {
        if orderTrackingData?.driver == nil {
            self.driverDetailsView.isHidden = true
        }        
        driverNameLabel.text = (orderTrackingData?.driver?.fullName() ?? "") + " is in a " + (orderTrackingData?.driver?.carName ?? "--")
        driverCodeLabel.text = orderTrackingData?.driver?.carNumber ?? "--"
        userAddressLabel.text = self.order.address?.fullAddress
        orderDeliveryTypeLabel.text = orderTrackingData?.deliveryType ?? "Deliver to door"
        
        if let profilePictureURL = orderTrackingData?.driver?.profilePictureURL, !profilePictureURL.isEmpty {
            driverImageView.kf.setImage(with: URL(string: profilePictureURL))
        }
        if let carPictureURL = orderTrackingData?.driver?.carPictureURL, !carPictureURL.isEmpty {
            driverCarImageView.kf.setImage(with: URL(string: carPictureURL))
        }
        driverImageView.layer.cornerRadius = driverImageView.frame.width / 2.0
        driverImageView.layer.borderColor = UIColor.white.darkModed.cgColor
        driverImageView.layer.borderWidth = 3

        driverCarImageView.layer.cornerRadius = driverCarImageView.frame.width / 2.0

        switch orderTrackingData?.status {
        case ATCOrderStatus.orderPlaced.rawValue:
            self.driverDetailsView.isHidden = true
        case ATCOrderStatus.driverAccepted.rawValue, ATCOrderStatus.orderShipped.rawValue:
            self.driverDetailsView.isHidden = false
        case ATCOrderStatus.inTransit.rawValue:
            self.driverDetailsView.isHidden = false
        default: break
        }
        
        if orderTrackingData?.pickUpAddress != nil {
            deliveryDetailsLabel.text = "Ride Details"
            deliveryTypeLabel.isHidden = true
            orderDeliveryTypeLabel.isHidden = true
            deliveryTypeSeparator.isHidden = true
            orderSummaryLabel.isHidden = true
            totalLabel.isHidden = true
            totalValueLabel.isHidden = true
            totalSeparator.isHidden = true
            if orderTrackingData?.status == ATCOrderStatus.inTransit.rawValue {
                userAddressLabel.text = self.order.dropAddress?.line1
            } else {
                userAddressLabel.text = self.order.pickUpAddress?.line1
            }
        }
    }
    
    @IBAction func showMoreItemsAction(_ sender: Any) {
        if isShowMoreCartEnable {
            foodItemsCollectionViewHeightConstraint.constant = cartScreenCellHeight * CGFloat(defaultNumberOfCartsNeedToShow) + CGFloat(cartManager.numberOfObjects() * 5)
            isShowMoreCartEnable = false
            showMoreLabel.text = "Show more"
            dropDownImageView.image = #imageLiteral(resourceName: "drop-down-icon")
        } else {
            foodItemsCollectionViewHeightConstraint.constant = cartScreenCellHeight * CGFloat(cartManager.numberOfObjects()) + CGFloat(cartManager.numberOfObjects() * 5)
            isShowMoreCartEnable = true
            showMoreLabel.text = "Show less"
            dropDownImageView.image = #imageLiteral(resourceName: "drop-up-icon")
        }
    }
    
    @IBAction func startChatAction(_ sender: Any) {
        if let viewer = self.user, let orderTrackingData = self.orderTrackingData, let driver = orderTrackingData.driver, let driverID = driver.uid {
            let recipient = ATCUser(uid: driverID, firstName: orderTrackingData.driver?.fullName(), lastName: "", avatarURL: "")
            let id1 = (recipient.uid ?? "")
            let id2 = (viewer.uid ?? "")
            let channelId = id1 < id2 ? id1 + id2 : id2 + id1
            var channel = ATCChatChannel(id: channelId, name: recipient.fullName())
            channel.participants = [recipient, viewer]
            let config = ATCChatUIConfiguration(uiConfig: uiConfig)
            let vc = ATCChatThreadViewController(user: viewer,
                                                 channel: channel,
                                                 uiConfig: config,
                                                 reportingManager: nil,
                                                 chatServiceConfig: chatServerConfig,
                                                 recipients: [recipient],
                                                 audioVideoChatPresenter: ATCAudioVideoChatPresenter())
            let navVC = UINavigationController(rootViewController: vc)
            self.present(navVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func startCallAction(_ sender: Any) {
        if chatServerConfig.isAudioCallingEnabled {
            if let viewer = self.user, let orderTrackingData = self.orderTrackingData, let driver = orderTrackingData.driver, let driverID = driver.uid {
                let recipient = ATCUser(uid: driverID, firstName: orderTrackingData.driver?.fullName(), lastName: "", avatarURL: "")
                let id1 = (recipient.uid ?? "")
                let id2 = (viewer.uid ?? "")
                let channelId = id1 < id2 ? id1 + id2 : id2 + id1
                var channel = ATCChatChannel(id: channelId, name: recipient.fullName())
                channel.participants = [recipient, viewer]
                let audioVideoChatPresenter = ATCAudioVideoChatPresenter()
                audioVideoChatPresenter.startCall(in: self, chatType: .audio, channel: channel, user: viewer, otherUser: recipient)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ATCDeliveryDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cartManager.numberOfObjects()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellReuseIdentifier, for: indexPath) as? CartItemCollectionViewCell else {
            fatalError()
        }
        let item = cartManager.object(at: indexPath.row)
        cell.configure(item: item, uiConfig: uiConfig)
        cell.cartItemTitleLabel.textColor = UIColor.gray.darkModed
        cell.cartPriceLabel.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: cartScreenCellHeight)
    }
}
