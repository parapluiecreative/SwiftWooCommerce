//
//  CheckoutViewController.swift
//  Standard Integration (Swift)
//
//  Created by Ben Guo on 4/22/16.
//  Copyright © 2016 Stripe. All rights reserved.
//

import UIKit
import Stripe
import GooglePlaces
import PassKit

protocol CheckoutViewControllerDelegate: class {
    func checkoutViewController(_ vc: CheckoutViewController, didCompleteCheckout address: ATCAddress)
}

class CheckoutViewController: UIViewController {

    // 1) To get started with this demo, first head to https://dashboard.stripe.com/account/apikeys
    // and copy your "Test Publishable Key" (it looks like pk_test_abcdef) into the line below.
    let stripePublishableKey = "pk_test_mHeSRjRFtORVXYQeFZty7pZD"

    // 2) Next, optionally, to have this demo save your user's payment details, head to
    // https://github.com/stripe/example-ios-backend/tree/v14.0.0, click "Deploy to Heroku", and follow
    // the instructions (don't worry, it's free). Replace nil on the line below with your
    // Heroku URL (it looks like https://blazing-sunrise-1234.herokuapp.com ).
    let backendBaseURL: String? = "https://shopertino-nov2019.herokuapp.com/"

    // 3) Optionally, to enable Apple Pay, follow the instructions at https://stripe.com/docs/mobile/apple-pay
    // to create an Apple Merchant ID. Replace nil on the line below with it (it looks like merchant.com.yourappname).
    let appleMerchantID: String? = "merchant.com.iosapptemplates"

    // These values will be shown to the user when they purchase with Apple Pay.
    let companyName = "Shopertino"
    let paymentCurrency = "usd"
    let country: String = "US"

    let paymentContext: STPPaymentContext

    let theme: STPTheme
    let paymentRow: CheckoutRowView
    var shippingRow: CheckoutRowView?
    let totalRow: CheckoutRowView
    let buyButton: UIButton
    let titleLabel: UILabel
    let rowHeight: CGFloat = 44
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    let numberFormatter: NumberFormatter
    let shippingString: String
    let products: [ATCShoppingCartProduct]
    var paymentInProgress: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                if self.paymentInProgress {
                    self.activityIndicator.startAnimating()
                    self.activityIndicator.alpha = 1
                    self.buyButton.alpha = 0
                }
                else {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.alpha = 0
                    self.buyButton.alpha = 1
                }
            }, completion: nil)
        }
    }

    private var redirectContext: STPRedirectContext?

    let uiConfig: ATCUIGenericConfigurationProtocol
    weak var delegate: CheckoutViewControllerDelegate?

    var fetcher: GMSAutocompleteFetcher?
    var shippingLocation: ATCLocation? = nil
    var shippingGoogleAddress: String = ""
    
    var dsProvider: ATCEcommerceDataSourceProvider?
    var user: ATCUser?
    var serverConfig: ATCOnboardingServerConfigurationProtocol
    var shippingAddress: ATCAddress?
    var cartManager: ATCShoppingCartManager?

    init(cartManager: ATCShoppingCartManager? = nil,
         uiConfig: ATCUIGenericConfigurationProtocol,
         price: Int,
         products: [ATCShoppingCartProduct],
         settings: Settings,
         serverConfig: ATCOnboardingServerConfigurationProtocol,
         dsProvider: ATCEcommerceDataSourceProvider? = nil,
         user: ATCUser? = nil) {
        self.cartManager = cartManager
        let stripePublishableKey = self.stripePublishableKey
        let backendBaseURL = self.backendBaseURL

        assert(stripePublishableKey.hasPrefix("pk_"), "You must set your Stripe publishable key at the top of CheckoutViewController.swift to run this app.")
        assert(backendBaseURL != nil, "You must set your backend base url at the top of CheckoutViewController.swift to run this app.")

        self.products = products
        self.uiConfig = uiConfig
        self.theme = settings.theme
        
        self.dsProvider = dsProvider
        self.user = user
        self.serverConfig = serverConfig

        MyAPIClient.sharedClient.baseURLString = self.backendBaseURL

        // This code is included here for the sake of readability, but in your application you should set up your configuration and theme earlier, preferably in your App Delegate.
        let config = STPPaymentConfiguration.shared
        config.publishableKey = self.stripePublishableKey
        config.appleMerchantIdentifier = self.appleMerchantID
        config.companyName = self.companyName
        config.requiredBillingAddressFields = settings.requiredBillingAddressFields
        config.requiredShippingAddressFields = settings.requiredShippingAddressFields
        config.shippingType = settings.shippingType

        // Create card sources instead of card tokens
        //        config.createCardSources = true;

        let customerContext = STPCustomerContext(keyProvider: MyAPIClient.sharedClient)
        let paymentContext = STPPaymentContext(customerContext: customerContext,
                                               configuration: config,
                                               theme: settings.theme)
        let userInformation = STPUserInformation()
        paymentContext.prefilledInformation = userInformation
        paymentContext.paymentAmount = price
        paymentContext.paymentCurrency = self.paymentCurrency

        //        let paymentSelectionFooter = PaymentContextFooterView(text: "You can add custom footer views to the payment selection screen.")
        //        paymentSelectionFooter.theme = settings.theme
        //        paymentContext.paymentOptionsViewControllerFooterView = paymentSelectionFooter
        //
        //        let addCardFooter = PaymentContextFooterView(text: "You can add custom footer views to the add card screen.")
        //        addCardFooter.theme = settings.theme
        //        paymentContext.addCardViewControllerFooterView = addCardFooter

        self.paymentContext = paymentContext

        self.paymentRow = CheckoutRowView(title: "Payment",
                                          detail: "Select Payment",
                                          theme: settings.theme)
        var shippingString = "Contact"
        if config.requiredShippingAddressFields?.contains(.postalAddress) ?? false {
            shippingString = config.shippingType == .shipping ? "Shipping" : "Delivery"
        }
        self.shippingString = shippingString
        if let requiredFields = config.requiredShippingAddressFields, !requiredFields.isEmpty {
            var shippingString = "Contact"
            if requiredFields.contains(.postalAddress) {
                shippingString = config.shippingType == .shipping ? "Ship to" : "Deliver to"
            }
            self.shippingRow = CheckoutRowView(title: shippingString,
                                               detail: "Select address",
            theme: settings.theme)
        } else {
            self.shippingRow = nil
        }

        self.totalRow = CheckoutRowView(title: "Total", detail: "", tappable: false,
                                        theme: settings.theme)
        self.buyButton = UIButton(type: .system)
        buyButton.configure(color: .white,
                            font: uiConfig.boldFont(size: 16),
                            cornerRadius: 5,
                            borderColor: nil,
                            backgroundColor: uiConfig.mainThemeForegroundColor)
        buyButton.setTitle("PLACE ORDER".localizedEcommerce, for: .normal)

        self.titleLabel = UILabel(frame: .zero)

        var localeComponents: [String: String] = [
            NSLocale.Key.currencyCode.rawValue: self.paymentCurrency,
        ]
        localeComponents[NSLocale.Key.languageCode.rawValue] = NSLocale.preferredLanguages.first
        let localeID = NSLocale.localeIdentifier(fromComponents: localeComponents)
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: localeID)
        numberFormatter.numberStyle = .currency
        numberFormatter.usesGroupingSeparator = true
        self.numberFormatter = numberFormatter
        super.init(nibName: nil, bundle: nil)
        self.paymentContext.delegate = self
        paymentContext.hostViewController = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexString: "#fafafa").darkModed

        var red: CGFloat = 0
        self.theme.primaryBackgroundColor.getRed(&red, green: nil, blue: nil, alpha: nil)
        self.activityIndicator.style = red < 0.5 ? .white : .gray
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.totalRow)
        self.view.addSubview(self.paymentRow)
        if let shippingRow = shippingRow {
            self.view.addSubview(shippingRow)
        }
        self.view.addSubview(self.buyButton)
        self.view.addSubview(self.activityIndicator)

        self.titleLabel.text = "Check out"
        self.titleLabel.font = uiConfig.boldFont(size: 34)
        self.titleLabel.textColor = uiConfig.mainTextColor.darkModed

        self.activityIndicator.alpha = 0
        self.buyButton.addTarget(self, action: #selector(didTapBuy), for: .touchUpInside)
        self.totalRow.detail = self.numberFormatter.string(from: NSNumber(value: Float(self.paymentContext.paymentAmount)/100))!
        self.paymentRow.onTap = { [weak self] in
            self?.paymentContext.pushPaymentOptionsViewController()
        }
        self.shippingRow?.onTap = { [weak self]  in
            guard let self = self else { return }
            let savedAddressVC = ATCSavedAddressViewController(uiConfig: self.uiConfig,
                                                            dsProvider: self.dsProvider,
                                                            viewer: self.user)
            savedAddressVC.isCheckoutHappening = true
            savedAddressVC.delegate = self
            let navController = UINavigationController(rootViewController: savedAddressVC)
            self.present(navController, animated: true, completion: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.paymentInProgress = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var insets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            insets = view.safeAreaInsets
        }
        let width = self.view.bounds.width - (insets.left + insets.right)
        let height = self.view.bounds.height - (insets.top + insets.bottom)

        self.titleLabel.frame = CGRect(x: insets.left + 15, y: insets.top + 20, width: width, height: 40)
        self.paymentRow.frame = CGRect(x: insets.left, y: self.titleLabel.frame.maxY + rowHeight + 10,
                                       width: width, height: rowHeight)
        self.shippingRow?.frame = CGRect(x: insets.left, y: self.paymentRow.frame.maxY,
                                        width: width, height: rowHeight)
        self.totalRow.frame = CGRect(x: insets.left, y: self.shippingRow?.frame.maxY ?? self.paymentRow.frame.maxY,
                                     width: width, height: rowHeight)
        self.buyButton.frame = CGRect(x: insets.left, y: height - 50, width: width - 20, height: 50)
        self.buyButton.center = CGPoint(x: width / 2.0, y: self.buyButton.center.y)
        self.activityIndicator.center = self.buyButton.center
    }

    @objc func didTapBuy() {
        self.paymentInProgress = true
        self.paymentContext.requestPayment()
    }
}

// MARK: STPPaymentContextDelegate
extension CheckoutViewController: STPPaymentContextDelegate {
    enum CheckoutError: Error {
        case unknown

        var localizedDescription: String {
            switch self {
                case .unknown:
                    return "Unknown error"
            }
        }
    }
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        // Create the PaymentIntent on the backend
        // To speed this up, create the PaymentIntent earlier in the checkout flow and update it as necessary (e.g. when the cart subtotal updates or when shipping fees and taxes are calculated, instead of re-creating a PaymentIntent for every payment attempt.
        MyAPIClient.sharedClient.createPaymentIntent(price: paymentContext.paymentAmount,
                                                     products: self.products,
                                                     shippingMethod: paymentContext.selectedShippingMethod,
                                                     country: self.country) { result in
                                                        switch result {
                case .success(let clientSecret):
                    // Confirm the PaymentIntent
                    let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
                    paymentIntentParams.configure(with: paymentResult)
                    paymentIntentParams.returnURL = "payments-example://stripe-redirect"
                    STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: paymentContext) { status, paymentIntent, error in
                        switch status {
                            case .succeeded:
                                // Our example backend asynchronously fulfills the customer's order via webhook
                                // See https://stripe.com/docs/payments/payment-intents/ios#fulfillment
                                completion(.success, nil)
                            case .failed:
                                completion(.error, error)
                            case .canceled:
                                completion(.userCancellation, nil)
                            @unknown default:
                                completion(.error, nil)
                        }
                }
                case .failure(let error):
                    // A real app should retry this request if it was a network error.
                    print("Failed to create a Payment Intent: \(error)")
                    completion(.error, error)
                    break
            }
        }
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        self.paymentInProgress = false
        let title: String
        let message: String
        switch status {
            case .error:
                title = "Error"
                message = error?.localizedDescription ?? ""
            case .success:
                title = "Success"
                message = "Your purchase was successful!"
                if let shippingAddress = shippingAddress {
                    self.delegate?.checkoutViewController(self, didCompleteCheckout: shippingAddress)
                } else {
                    self.delegate?.checkoutViewController(self, didCompleteCheckout: convertStripeAddressToATCAddress(stripeAddress: paymentContext.shippingAddress))
                }
                self.navigationController?.popViewController(animated: true)
            case .userCancellation:
                return()
            @unknown default:
                return()
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }

    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        self.paymentRow.loading = paymentContext.loading
        if let paymentOption = paymentContext.selectedPaymentOption {
            self.paymentRow.detail = paymentOption.label
        } else {
            self.paymentRow.detail = "Select Payment"
        }
        if let shippingMethod = paymentContext.selectedShippingMethod {
            self.shippingRow?.detail = shippingMethod.label
        } else {
            self.shippingRow?.detail = "Select address"
        }
        self.totalRow.detail = self.numberFormatter.string(from: NSNumber(value: Float(self.paymentContext.paymentAmount)/100))!
        buyButton.isEnabled = paymentContext.selectedPaymentOption != nil && ((paymentContext.shippingAddress != nil || shippingAddress != nil) || self.shippingRow == nil)
        if let shippingAddress = shippingAddress, let line1 = shippingAddress.line1, let city = shippingAddress.city, let state = shippingAddress.state, let postalCode = shippingAddress.postalCode {
            let searchAddress = line1+" "+city+" "+state+" "+postalCode
            self.shippingRow?.detail = searchAddress.count > 20 ? (searchAddress as NSString).substring(with: NSRange(location: 0, length: 20)) : searchAddress
        }
        
        if let line1 = paymentContext.shippingAddress?.line1, !line1.isEmpty, let city = paymentContext.shippingAddress?.city, !city.isEmpty, let state = paymentContext.shippingAddress?.state, !state.isEmpty, let postalCode = paymentContext.shippingAddress?.postalCode, !postalCode.isEmpty {
            let searchAddress = line1+" "+city+" "+state+" "+postalCode
            
            self.shippingRow?.detail = searchAddress.count > 20 ? (searchAddress as NSString).substring(with: NSRange(location: 0, length: 20)) : searchAddress
            if shippingGoogleAddress != searchAddress {
                shippingGoogleAddress = searchAddress
                fetcher?.sourceTextHasChanged(searchAddress)
            }
        }
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        let alertController = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // Need to assign to _ because optional binding loses @discardableResult value
            // https://bugs.swift.org/browse/SR-1681
            _ = self.navigationController?.popViewController(animated: true)
        })
        let retry = UIAlertAction(title: "Retry", style: .default, handler: { action in
            self.paymentContext.retryLoading()
        })
        alertController.addAction(cancel)
        alertController.addAction(retry)
        self.present(alertController, animated: true, completion: nil)
    }

    // Note: this delegate method is optional. If you do not need to collect a
    // shipping method from your user, you should not implement this method.
    func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        let upsGround = PKShippingMethod()
        upsGround.amount = 0
        upsGround.label = "UPS Ground"
        upsGround.detail = "Arrives in 3-5 days"
        upsGround.identifier = "ups_ground"
        let upsWorldwide = PKShippingMethod()
        upsWorldwide.amount = 10.99
        upsWorldwide.label = "UPS Worldwide Express"
        upsWorldwide.detail = "Arrives in 1-3 days"
        upsWorldwide.identifier = "ups_worldwide"
        let fedEx = PKShippingMethod()
        fedEx.amount = 5.99
        fedEx.label = "FedEx"
        fedEx.detail = "Arrives tomorrow"
        fedEx.identifier = "fedex"

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if address.country == nil || address.country == "US" {
                completion(.valid, nil, [upsGround, fedEx], fedEx)
            } else if address.country == "AQ" {
                let error = NSError(domain: "ShippingError", code: 123, userInfo: [NSLocalizedDescriptionKey: "Invalid Shipping Address",
                                                                                   NSLocalizedFailureReasonErrorKey: "We can't ship to this country."])
                completion(.invalid, error, nil, nil)
            } else {
                fedEx.amount = 20.99
                fedEx.identifier = "fedex_world"
                completion(.valid, nil, [upsWorldwide, fedEx], fedEx)
            }
        }
    }
}

extension CheckoutViewController {
    fileprivate func convertStripeAddressToATCAddress(stripeAddress: STPAddress?) -> ATCAddress {
        guard let stripeAddress = stripeAddress else { return ATCAddress() }
        return ATCAddress(name: stripeAddress.name,
                          line1: stripeAddress.line1,
                          line2: stripeAddress.line2,
                          city:stripeAddress.city,
                          state: stripeAddress.state,
                          postalCode: stripeAddress.postalCode,
                          country: stripeAddress.country,
                          phone: stripeAddress.phone,
                          email: stripeAddress.email,
                          location: shippingLocation)
    }
}

extension CheckoutViewController: GMSAutocompleteFetcherDelegate {
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        if predictions.count > 0 {
            let placeClient = GMSPlacesClient()
            placeClient.lookUpPlaceID(predictions[0].placeID) { [weak self] (place, error) in
                guard let `self` = self else { return }
                if error == nil, let place = place {
                    self.shippingLocation = ATCLocation(longitude: place.coordinate.longitude, latitude: place.coordinate.latitude)
                }
            }
        }
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        
    }
}

extension CheckoutViewController: ATCSavedAddressViewControllerDelegate {
    func didSelectAddress(address: ATCAddress) {
        shippingAddress = address
        paymentContextDidChange(paymentContext)
        let shippingAddress = STPAddress()
        shippingAddress.name = address.name
        shippingAddress.city = address.city
        shippingAddress.country = address.country
        shippingAddress.line1 = address.line1
        shippingAddress.line2 = address.line2
        shippingAddress.postalCode = address.postalCode
        shippingAddress.state = address.state
        paymentContext.shippingAddressViewController(STPShippingAddressViewController(), didFinishWith: shippingAddress, shippingMethod: paymentContext.selectedShippingMethod)
    }
}
