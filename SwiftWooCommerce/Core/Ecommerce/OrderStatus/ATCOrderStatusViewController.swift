//
//  ATCOrderStatusViewController.swift
//  MultiVendorApp
//
//  Created by Mac  on 04/06/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit
import GoogleMaps

let kOrderCompleteNotificationName = NSNotification.Name(rawValue: "kOrderCompleteNotificationName")

class ATCOrderStatusViewController: UIViewController {

    @IBOutlet weak var estimatedDataView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var estimatedTimeLabel: UILabel!
    @IBOutlet weak var timeProgressView: UIProgressView!
    @IBOutlet weak var preparingLabel: UILabel!
    @IBOutlet weak var lastArrivalLabel: UILabel!
    @IBOutlet weak var orderStatusImage: UIImageView!
    @IBOutlet weak var deliveryDetailsContainerView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    
    let uiConfig: ATCUIGenericConfigurationProtocol
    let serverConfig: ATCOnboardingServerConfigurationProtocol
    let cartManager: ATCShoppingCartManager?
    let order: ATCOrder?
    var user: ATCUser?
    var manager: ATCFirebaseOrderTracker?
    var driverTrackingManager: ATCFirebaseDriverTracker?
    var orderTrackingData: ATCOrder?
    var orderRequestData: ATCDriverOrderRequestData? = nil {
        didSet {
            updateTrip()
        }
    }
    
    var driverTrackingData: ATCUser?
    var isDriverIdCaptured: Bool = false
    
    var lastLocationUpdatedTime: Date?
    var lastLocationUpdateTimeInterval = 300
    let dsProvider: ATCEcommerceDataSourceProvider

    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         uiConfig: ATCUIGenericConfigurationProtocol,
         serverConfig: ATCOnboardingServerConfigurationProtocol,
         cartManager: ATCShoppingCartManager?,
         order: ATCOrder?,
         user: ATCUser?,
         dsProvider: ATCEcommerceDataSourceProvider) {
        self.uiConfig = uiConfig
        self.serverConfig = serverConfig
        self.cartManager = cartManager
        self.order = order
        self.user = user
        self.manager = ATCFirebaseOrderTracker()
        self.driverTrackingManager = ATCFirebaseDriverTracker()
        self.dsProvider = dsProvider
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeLabel.font = uiConfig.regularFont(size: 28)
        timeLabel.textColor = uiConfig.mainTextColor
        
        estimatedTimeLabel.text = "Estimated Time".localizedEcommerce
        estimatedTimeLabel.font = uiConfig.regularFont(size: 15)
        estimatedTimeLabel.textColor = uiConfig.mainSubtextColor

        preparingLabel.font = uiConfig.boldFont(size: 17)
        preparingLabel.textColor = UIColor.darkGray.darkModed
        
        lastArrivalLabel.font = uiConfig.regularFont(size: 15)
        lastArrivalLabel.textColor = uiConfig.mainSubtextColor
        
        timeProgressView.tintColor = uiConfig.mainThemeForegroundColor

        if let cartManager = cartManager, let order = order {
            let deliveryDetailsVC = ATCDeliveryDetailsViewController(nibName: "ATCDeliveryDetailsViewController",
                                                                     bundle: nil,
                                                                     uiConfig: self.uiConfig,
                                                                     cartManager: cartManager,
                                                                     orderTrackingData: self.orderTrackingData,
                                                                     order: order,
                                                                     user: self.user)
            self.addChildViewControllerWithView(deliveryDetailsVC, toView: deliveryDetailsContainerView)
            
            self.manager?.observerSignal(forOrder: order.id, tableName: dsProvider.firebaseOrdersTableName, completion: { (orderTrackData) in
                self.orderTrackingData = orderTrackData
                deliveryDetailsVC.updateDriverInfo(orderTrackingData: self.orderTrackingData)
                if !self.isDriverIdCaptured && !(orderTrackData.driver?.uid?.isEmpty ?? true) {
                    if let driverId = orderTrackData.driver?.uid {
                        self.fetchDriverLocation(driverId: driverId)
                        self.isDriverIdCaptured = true
                    }
                }
                switch orderTrackData.status {
                case ATCOrderStatus.orderPlaced.rawValue:
                    if orderTrackData.pickUpAddress != nil {
                        self.preparingLabel.text = "Confirming your ride...".localizedEcommerce
                        self.lastArrivalLabel.isHidden = true
                    } else {
                        self.preparingLabel.text = "Confirming your order...".localizedEcommerce
                    }
                    self.mapView.isHidden = true
                    self.estimatedTimeLabel.isHidden = true
                    self.estimatedDataView.isHidden = true
                    self.timeProgressView.progress = 0.0
                case ATCOrderStatus.orderAccepted.rawValue, ATCOrderStatus.driverPending.rawValue, ATCOrderStatus.driverRejected.rawValue:
                    if orderTrackData.pickUpAddress != nil {
                        self.preparingLabel.text = "Confirming your ride...".localizedEcommerce
                        self.lastArrivalLabel.isHidden = true
                    } else {
                        self.preparingLabel.text = "Preparing your order...".localizedEcommerce
                    }
                    self.mapView.isHidden = true
                    self.timeProgressView.progress = 0.2
                    if let date = Calendar.current.date(
                        byAdding: .hour,
                        value: 1,
                        to: Date()) {
                        self.timeLabel.text = TimeFormatHelper.string(for: date, format: "HH:mm")
                        if let latestArrivalDate = Calendar.current.date(
                            byAdding: .minute,
                            value: 20,
                            to: date) {
                            self.lastArrivalLabel.text = "Latest arrival by".localizedEcommerce + " " + TimeFormatHelper.string(for: latestArrivalDate, format: "HH:mm")
                        }
                    }
                    self.estimatedTimeLabel.isHidden = false
                    self.estimatedDataView.isHidden = false
                case ATCOrderStatus.orderRejected.rawValue:
                    if orderTrackData.pickUpAddress != nil {
                        self.preparingLabel.text = "Your ride rejected...".localizedEcommerce
                        self.lastArrivalLabel.isHidden = true
                    } else {
                        self.preparingLabel.text = "Your order rejected...".localizedEcommerce
                    }
                    self.mapView.isHidden = true
                    self.estimatedTimeLabel.isHidden = true
                    self.estimatedDataView.isHidden = true
                    self.timeProgressView.progress = 0.0
                case ATCOrderStatus.driverAccepted.rawValue, ATCOrderStatus.orderShipped.rawValue:
                    if orderTrackData.pickUpAddress != nil {
                        self.preparingLabel.text = "\(orderTrackData.driver?.fullName() ?? "") is on the way"
                        self.lastArrivalLabel.isHidden = true
                    } else {
                        self.preparingLabel.text = "\(orderTrackData.driver?.fullName() ?? "") is picking up your order"
                    }
                    self.mapView.isHidden = false
                    self.updateRoute(driverData: self.driverTrackingData, isForceUpdateRoute: true, isTaxi: orderTrackData.pickUpAddress != nil)
                    self.calculateEstimatedTimeArrival()
                    self.timeProgressView.progress = 0.6
                case ATCOrderStatus.inTransit.rawValue:
                    if orderTrackData.pickUpAddress != nil {
                        self.preparingLabel.text = "\(orderTrackData.driver?.fullName() ?? "")"
                        self.lastArrivalLabel.isHidden = true
                    } else {
                        self.preparingLabel.text = "Your food is on the way"
                    }
                    self.mapView.isHidden = false
                    self.updateRoute(driverData: self.driverTrackingData, isForceUpdateRoute: true, isTaxi: orderTrackData.pickUpAddress != nil)
                    self.calculateEstimatedTimeArrival()
                    self.timeProgressView.progress = 0.8
                case ATCOrderStatus.orderCompleted.rawValue:
                    self.timeProgressView.progress = 1.0
                    self.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: kDismissChatNotificationName, object: nil)
                    NotificationCenter.default.post(name: kOrderCompleteNotificationName, object: nil)
                default: break
                }
            })
        }
        deliveryDetailsContainerView.dropTopShadow()
    }
    
    func updateTrip() {
        self.preparingLabel.isHidden = true
        self.estimatedTimeLabel.isHidden = true
        self.estimatedDataView.isHidden = true
        self.timeProgressView.isHidden = true
        
        if let orderRequestData = orderRequestData {
            if !self.isDriverIdCaptured && !orderRequestData.driverID.isEmpty {
                self.fetchDriverLocation(driverId: orderRequestData.driverID)
                self.isDriverIdCaptured = true
            }
            switch orderRequestData.orderStatus {
            case ATCOrderStatus.driverAccepted.rawValue, ATCOrderStatus.orderShipped.rawValue:
                self.mapView.isHidden = false
            case ATCOrderStatus.inTransit.rawValue:
                self.mapView.isHidden = false
                self.updateRoute(driverData: self.driverTrackingData, isForceUpdateRoute: true, isTaxi: self.orderTrackingData?.pickUpAddress != nil)
            case ATCOrderStatus.orderCompleted.rawValue:
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: kDismissChatNotificationName, object: nil)
                NotificationCenter.default.post(name: kOrderCompleteNotificationName, object: nil)
            default: break
            }
        }
    }
    
    func calculateEstimatedTimeArrival() {
        guard let orderTrackingData = orderTrackingData else { return }
        guard let driverTrackingData = driverTrackingData else { return }
        switch orderTrackingData.status {
        case ATCOrderStatus.orderPlaced.rawValue, ATCOrderStatus.driverPending.rawValue:
            if orderTrackingData.pickUpAddress != nil {
                self.estimatedTimeLabel.isHidden = true
                self.estimatedDataView.isHidden = true
            } else {
                ATCGoogleDistanceMatrixManager.retriveEstimatedTimeData(originLatitude: driverTrackingData.location?.latitude ?? 0.0,
                                                                        originLongitude: driverTrackingData.location?.longitude ?? 0.0,
                                                                        destinationLatitude: orderTrackingData.shoppingCart?.vendor?.coordinate.latitude ?? 0.0,
                                                                        destinationLongitude: orderTrackingData.shoppingCart?.vendor?.coordinate.longitude ?? 0.0,
                                                                        serverConfig: serverConfig) { (pickupDistance, pickupDuration) in
                                                                            ATCGoogleDistanceMatrixManager.retriveEstimatedTimeData(originLatitude: driverTrackingData.location?.latitude ?? 0.0,
                                                                                                                                    originLongitude: driverTrackingData.location?.longitude ?? 0.0,
                                                                            destinationLatitude: orderTrackingData.address?.location?.latitude ?? 0.0,
                                                                            destinationLongitude: orderTrackingData.address?.location?.longitude ?? 0.0,
                                                                            serverConfig: self.serverConfig) { (dropDistance, dropDuration) in
                                                                                let calculatedTime = Date(timeIntervalSinceNow: TimeInterval(pickupDuration.value+dropDuration.value+600))
                        self.timeLabel.text = TimeFormatHelper.string(for: calculatedTime, format: "HH:mm")
                        if let latestArrivalDate = Calendar.current.date(
                            byAdding: .minute,
                            value: 20,
                            to: calculatedTime) {
                            self.lastArrivalLabel.text = "Latest arrival by".localizedEcommerce + " " + TimeFormatHelper.string(for: latestArrivalDate, format: "HH:mm")
                        }
                        self.estimatedTimeLabel.isHidden = false
                        self.estimatedDataView.isHidden = false
                    }
                }
            }
        case ATCOrderStatus.driverAccepted.rawValue, ATCOrderStatus.orderShipped.rawValue:
            if orderTrackingData.pickUpAddress != nil {
                ATCGoogleDistanceMatrixManager.retriveEstimatedTimeData(originLatitude: driverTrackingData.location?.latitude ?? 0.0,
                                                                        originLongitude: driverTrackingData.location?.longitude ?? 0.0,
                                                                        destinationLatitude: orderTrackingData.pickUpAddress?.location?.latitude ?? 0.0,
                                                                        destinationLongitude: orderTrackingData.pickUpAddress?.location?.longitude ?? 0.0,
                                                                        serverConfig: self.serverConfig) { (pickupDistance, pickupDuration) in
                    let calculatedTime = Date(timeIntervalSinceNow: TimeInterval(pickupDuration.value))
                    self.timeLabel.text = TimeFormatHelper.string(for: calculatedTime, format: "HH:mm")
                    if let latestArrivalDate = Calendar.current.date(
                        byAdding: .minute,
                        value: 20,
                        to: calculatedTime) {
                        self.lastArrivalLabel.text = "Latest arrival by".localizedEcommerce + " " + TimeFormatHelper.string(for: latestArrivalDate, format: "HH:mm")
                    }
                    self.estimatedTimeLabel.isHidden = false
                    self.estimatedDataView.isHidden = false
                }
            } else {
                ATCGoogleDistanceMatrixManager.retriveEstimatedTimeData(originLatitude: driverTrackingData.location?.latitude ?? 0.0,
                                                                        originLongitude: driverTrackingData.location?.longitude ?? 0.0,
                                                                        destinationLatitude: orderTrackingData.shoppingCart?.vendor?.coordinate.latitude ?? 0.0,
                                                                        destinationLongitude: orderTrackingData.shoppingCart?.vendor?.coordinate.longitude ?? 0.0,
                                                                        serverConfig: serverConfig) { (pickupDistance, pickupDuration) in
                                                                            ATCGoogleDistanceMatrixManager.retriveEstimatedTimeData(originLatitude: driverTrackingData.location?.latitude ?? 0.0,
                                                                                                                                    originLongitude: driverTrackingData.location?.longitude ?? 0.0,
                                                                            destinationLatitude: orderTrackingData.address?.location?.latitude ?? 0.0, destinationLongitude: orderTrackingData.address?.location?.longitude ?? 0.0, serverConfig: self.serverConfig) { (dropDistance, dropDuration) in
                                                                                let calculatedTime = Date(timeIntervalSinceNow: TimeInterval(pickupDuration.value+dropDuration.value))
                        self.timeLabel.text = TimeFormatHelper.string(for: calculatedTime, format: "HH:mm")
                        if let latestArrivalDate = Calendar.current.date(
                            byAdding: .minute,
                            value: 20,
                            to: calculatedTime) {
                            self.lastArrivalLabel.text = "Will arrive by".localizedEcommerce + " " + TimeFormatHelper.string(for: latestArrivalDate, format: "HH:mm")
                        }
                        self.estimatedTimeLabel.isHidden = false
                        self.estimatedDataView.isHidden = false
                    }
                }
            }
        case ATCOrderStatus.inTransit.rawValue:
            if orderTrackingData.pickUpAddress != nil {
                ATCGoogleDistanceMatrixManager.retriveEstimatedTimeData(originLatitude: driverTrackingData.location?.latitude ?? 0.0,
                                                                        originLongitude: driverTrackingData.location?.longitude ?? 0.0,
                                                                        destinationLatitude: orderTrackingData.dropAddress?.location?.latitude ?? 0.0,
                                                                        destinationLongitude: orderTrackingData.dropAddress?.location?.longitude ?? 0.0,
                                                                        serverConfig: self.serverConfig) { (dropDistance, dropDuration) in
                    let calculatedTime = Date(timeIntervalSinceNow: TimeInterval(dropDuration.value))
                    self.timeLabel.text = TimeFormatHelper.string(for: calculatedTime, format: "HH:mm")
                    if let latestArrivalDate = Calendar.current.date(
                        byAdding: .minute,
                        value: 20,
                        to: calculatedTime) {
                        self.lastArrivalLabel.text = "Will reach by".localizedEcommerce + " " + TimeFormatHelper.string(for: latestArrivalDate, format: "HH:mm")
                    }
                    self.estimatedTimeLabel.isHidden = false
                    self.estimatedDataView.isHidden = false
                }
            } else {
                ATCGoogleDistanceMatrixManager.retriveEstimatedTimeData(originLatitude: driverTrackingData.location?.latitude ?? 0.0,
                                                                        originLongitude: driverTrackingData.location?.longitude ?? 0.0,
                                                                        destinationLatitude: orderTrackingData.address?.location?.latitude ?? 0.0,
                                                                        destinationLongitude: orderTrackingData.address?.location?.longitude ?? 0.0,
                                                                        serverConfig: self.serverConfig) { (dropDistance, dropDuration) in
                    let calculatedTime = Date(timeIntervalSinceNow: TimeInterval(dropDuration.value))
                    self.timeLabel.text = TimeFormatHelper.string(for: calculatedTime, format: "HH:mm")
                    if let latestArrivalDate = Calendar.current.date(
                        byAdding: .minute,
                        value: 20,
                        to: calculatedTime) {
                        self.lastArrivalLabel.text = "Latest arrival by".localizedEcommerce + " " + TimeFormatHelper.string(for: latestArrivalDate, format: "HH:mm")
                    }
                    self.estimatedTimeLabel.isHidden = false
                    self.estimatedDataView.isHidden = false
                }
            }
        default: break
        }
    }
    
    func fetchDriverLocation(driverId: String) {
        self.driverTrackingManager?.observerSignal(forDriver: driverId) { (driverData) in
            if self.driverTrackingData == nil {
                self.driverTrackingData = driverData
                self.updateRoute(driverData: self.driverTrackingData, isForceUpdateRoute: true, isTaxi: self.orderTrackingData?.pickUpAddress != nil)
                self.calculateEstimatedTimeArrival()
            } else {
                self.driverTrackingData = driverData
            }
            self.updateRoute(driverData: driverData, isTaxi: self.orderTrackingData?.pickUpAddress != nil)
        }
    }
    
    func updateRoute(driverData: ATCUser?, isForceUpdateRoute: Bool = false, isTaxi: Bool) {
        
        guard let driverData = driverData else {
            return
        }
        
        var needLocationUpdate: Bool = false
        
        if let lastLocationUpdatedTime = self.lastLocationUpdatedTime {
            let difference = Calendar.current.dateComponents([.second], from: lastLocationUpdatedTime, to: Date())
            if let inSeconds = difference.second, inSeconds >= self.lastLocationUpdateTimeInterval {
                needLocationUpdate = true
            }
        }
        
        if self.lastLocationUpdatedTime == nil || needLocationUpdate || isForceUpdateRoute {
            
            self.lastLocationUpdatedTime = Date()
            
            var destinationMarkerIcon = UIImage.localImage("pickup-marker-icon")

            var destinationLatitude: Double = 0.0
            var destinationLongitude: Double = 0.0
            
            if !isTaxi {
                switch self.orderTrackingData?.status {
                case ATCOrderStatus.orderPlaced.rawValue:
                    destinationLatitude = self.orderTrackingData?.shoppingCart?.vendor?.coordinate.latitude ?? 0.0
                    destinationLongitude = self.orderTrackingData?.shoppingCart?.vendor?.coordinate.longitude ?? 0.0
                case ATCOrderStatus.driverAccepted.rawValue, ATCOrderStatus.orderShipped.rawValue:
                    destinationLatitude = self.orderTrackingData?.shoppingCart?.vendor?.coordinate.latitude ?? 0.0
                    destinationLongitude = self.orderTrackingData?.shoppingCart?.vendor?.coordinate.longitude ?? 0.0
                case ATCOrderStatus.inTransit.rawValue:
                    destinationLatitude = self.orderTrackingData?.address?.location?.latitude ?? 0.0
                    destinationLongitude = self.orderTrackingData?.address?.location?.longitude ?? 0.0
                    destinationMarkerIcon = UIImage.localImage("dropoff-marker-icon")
                default: break
                }
            } else {
                switch self.orderTrackingData?.status {
                case ATCOrderStatus.driverAccepted.rawValue, ATCOrderStatus.orderShipped.rawValue:
                    destinationLatitude = self.orderTrackingData?.pickUpAddress?.location?.latitude ?? 0.0
                    destinationLongitude = self.orderTrackingData?.pickUpAddress?.location?.longitude ?? 0.0
                case ATCOrderStatus.inTransit.rawValue:
                    destinationLatitude = self.orderTrackingData?.dropAddress?.location?.latitude ?? 0.0
                    destinationLongitude = self.orderTrackingData?.dropAddress?.location?.longitude ?? 0.0
                    destinationMarkerIcon = UIImage.localImage("dropoff-marker-icon")
                default: break
                }
            }
            
            ATCGoogleDirectionsManager.retrivePolylineData(originLatitude: driverData.location?.latitude ?? 0.0,
                                                           originLongitude: driverData.location?.longitude ?? 0.0,
                                                           destinationLatitude: destinationLatitude,
                                                           destinationLongitude: destinationLongitude,
                                                           serverConfig: serverConfig) { (polypoints) in
                self.mapView.clear()
                
                let originMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: driverData.location?.latitude ?? 0.0, longitude: driverData.location?.longitude ?? 0.0))
                originMarker.icon = UIImage.localImage("driver-icon")
                originMarker.map = self.mapView
                
                let destinationMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: destinationLatitude, longitude: destinationLongitude))
                destinationMarker.icon = destinationMarkerIcon
                destinationMarker.map = self.mapView

                let path = GMSMutablePath(fromEncodedPath: polypoints)
                let polyLine = GMSPolyline(path: path)
                polyLine.strokeWidth = 5
                polyLine.strokeColor = UIColor.black
                polyLine.map = self.mapView
                
                let camera = GMSCameraPosition(latitude: driverData.location?.latitude ?? 0.0, longitude: driverData.location?.longitude ?? 0.0, zoom: 16)
                self.mapView.camera = camera
            }
        }
    }
    
    @IBAction func showDeliveryDetails(_ sender: Any) {
        if let cartManager = cartManager, let order = order {
            let deliveryDetailsVC = ATCDeliveryDetailsViewController(nibName: "ATCDeliveryDetailsViewController",
                                                                     bundle: nil,
                                                                     uiConfig: self.uiConfig,
                                                                     cartManager: cartManager,
                                                                     orderTrackingData: self.orderTrackingData,
                                                                     order: order,
                                                                     user: self.user)
            self.present(deliveryDetailsVC, animated: true, completion: nil)
        }
    }
    
    deinit {
        self.manager?.removeSignal()
        self.driverTrackingManager?.removeSignal()
    }
    
}
