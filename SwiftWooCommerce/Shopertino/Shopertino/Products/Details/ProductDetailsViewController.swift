//
//  ProductDetailsViewController.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/5/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import PassKit
import UIKit
import SafariServices

class ProductDetailsViewController: UIViewController {

    @IBOutlet var containerView: UIView!
    @IBOutlet var topContainerView: UIView!
    @IBOutlet var photoCarouselContainerView: UIView!
    @IBOutlet var colorsContainerView: UIView!
    @IBOutlet var caretButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var bottomContainerView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var borderView: UIView!
    @IBOutlet var buttonContainerView: UIView!
    @IBOutlet var addToBagButton: UIButton!
    @IBOutlet var applePayButton: UIButton!
    @IBOutlet var saveButton: InstaRoundImageButton!
    @IBOutlet var sizesContainerView: UIView!
    
    let product: Product
    let uiConfig: ATCUIGenericConfigurationProtocol
    var imageVC: ProductImagesViewController?
    let cartManager: ATCShoppingCartManager
    let placeOrderManager: ATCPlaceOrderManagerProtocol?
    let user: ATCUser?

    var selectedColor: String?
    var selectedSize: String?
    var currentImage: UIImage?

    let savedStore = ATCDiskPersistenceStore(key: "com.shopertino.wishlist")
    var dsProvider: ATCEcommerceDataSourceProvider?
    var payCart = ATCShoppingCart()
    init(product: Product,
         cartManager: ATCShoppingCartManager,
         user: ATCUser?,
         placeOrderManager: ATCPlaceOrderManagerProtocol? = nil,
         uiConfig: ATCUIGenericConfigurationProtocol,
         dsProvider: ATCEcommerceDataSourceProvider?) {

        self.product = product
        self.uiConfig = uiConfig
        self.dsProvider = dsProvider
        self.cartManager = cartManager
        self.placeOrderManager = placeOrderManager
        self.user = user

        if product.colors.count > 0 {
            selectedColor = product.colors[0]
        }

        if product.sizes.count > 0 {
            selectedSize = product.sizes[0]
        }

        super.init(nibName: "ProductDetailsViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: UIApplication.shared.statusBarFrame.height))
        let blurEffect = UIBlurEffect(style: .dark) // Set any style you want(.light or .dark) to achieve different effect.
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = statusBarView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        statusBarView.addSubview(blurEffectView)
        view.addSubview(statusBarView)

        imageVC = ProductImagesViewController(product: product,
                                              uiConfig: uiConfig,
                                              imageDelegate: self,
                                              cellHeight: photoCarouselContainerView.frame.height - 50)
        if let imageVC = imageVC {
            self.addChildViewControllerWithView(imageVC, toView: photoCarouselContainerView)
            imageVC.view.frame = photoCarouselContainerView.bounds
            imageVC.view.setNeedsLayout()
            imageVC.view.layoutIfNeeded()
        }

        if product.colors.count > 0 {
            let colorVC = ColorSelectorViewController(colors: product.colors, uiConfig: uiConfig, cellType: .large)
            colorVC.delegate = self
            self.addChildViewControllerWithView(colorVC, toView: colorsContainerView)
            colorVC.view.frame = colorsContainerView.bounds
        }

        if product.sizes.count > 0 {
            let sizeVC = SizeSelectorViewController(sizes: product.sizes, uiConfig: uiConfig, cellType: .large)
            sizeVC.delegate = self
            self.addChildViewControllerWithView(sizeVC, toView: sizesContainerView)
            sizeVC.view.frame = sizesContainerView.bounds
        }

        caretButton.configure(icon: UIImage.localImage("caret-icon", template: true))
        caretButton.tintColor = UIColor(hexString: "#938894")
        caretButton.addTarget(self, action: #selector(didTapCaretButton), for: .touchUpInside)

        shareButton.configure(icon: UIImage.localImage("share-icon-3-dots", template: true))
        shareButton.tintColor = UIColor(hexString: "#938894")
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)


        updateSaveButton()
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)

        addToBagButton.configure(color: .white,
                                 font: uiConfig.regularFont(size: 18),
                                 cornerRadius: 3,
                                 borderColor: nil,
                                 backgroundColor: UIColor(hexString: "#333333"))
        addToBagButton.addTarget(self, action: #selector(didTapAddToBagButton), for: .touchUpInside)
        addToBagButton.setTitle("ADD TO BAG".localizedInApp, for: .normal)

        applePayButton.configure(color: UIColor(hexString: "#313032"),
                                 font: uiConfig.regularFont(size: 18),
                                 cornerRadius: 3,
                                 borderColor: UIColor(hexString: "#313032"),
                                 backgroundColor: .white,
                                 borderWidth: 1)
        applePayButton.configure(icon: UIImage.localImage("apple-filled-icon", template: true).image(resizedTo: CGSize(width: 20, height: 20))!,
                                 color: UIColor(hexString: "#313032"))
        applePayButton.addTarget(self, action: #selector(didTapApplePayButton), for: .touchUpInside)
        applePayButton.setTitle("Pay".localizedInApp, for: .normal)

        colorsContainerView.backgroundColor = .clear
        sizesContainerView.backgroundColor = .clear

        titleLabel.text = product.title
        titleLabel.textColor = uiConfig.mainTextColor
        titleLabel.font = uiConfig.regularFont(size: 18.0)

        priceLabel.text = "$" +  (Double(product.price)?.twoDecimals() ?? 0.00).twoDecimalsString()
        priceLabel.textColor = uiConfig.mainSubtextColor
        priceLabel.font = uiConfig.regularFont(size: 14.0)

        borderView.backgroundColor = uiConfig.hairlineColor
        bottomContainerView.backgroundColor = .white
        buttonContainerView.backgroundColor = .white
        containerView.backgroundColor = .white
    }

    private func updateSaveButton() {
        let tintColorHex = (savedStore.contains(object: product) ? "#fb898e" : "#d5d5d5")
        saveButton.configure(image: UIImage.localImage("heart-filled-icon", template: true).image(resizedTo: CGSize(width: 25, height: 25))!,
                             tintColor: UIColor(hexString: tintColorHex),
                             bgColor: .white)
    }

    @objc private func didTapApplePayButton() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        let applePayManager = ATCApplePayManager(items: [
            PKPaymentSummaryItem(label: "Total for ".localizedInApp + product.title,
                                 amount: NSDecimalNumber(floatLiteral: self.product.cartPrice),
                                 type: .final)
            ])
        if let applePayVC = applePayManager.paymentViewController() {
            applePayVC.delegate = self
            self.present(applePayVC, animated: true, completion: nil)
        } else {
        }
    }

    @objc private func didTapAddToBagButton() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        cartManager.addProduct(product: product,
                               vendorID: user?.uid,
                               quantity: 1,
                               selectedColor: selectedColor,
                               selectedSize: selectedSize)
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func didTapShareButton() {
        let firstActivityItem = product.title
        let secondActivityItem : NSURL = NSURL(string: product.imageURLString)!
        var items: [Any] = [firstActivityItem, secondActivityItem]
        // If you want to put an image
        if let image = currentImage {
            items = [firstActivityItem, secondActivityItem, image]
        }
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: items, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (type, success, array, error) in
            if error == nil {

            }
        }

        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = shareButton

        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = .down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)

        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            .postToWeibo,
            .postToTencentWeibo,
            .print,
            .postToFlickr,
            .postToVimeo
        ]

        self.present(activityViewController, animated: true, completion: nil)
    }

    @objc private func didTapCaretButton() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func didTapSaveButton() {
        if (savedStore.contains(object: product)) {
            savedStore.remove(object: product)
        } else {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            savedStore.append(object: product)
        }
        updateSaveButton()
    }
}

extension ProductDetailsViewController: ColorSelectorViewControllerDelegate {
    func colorSelectorViewController(_ colorSelectorViewController: ColorSelectorViewController, didSelect color: String) {
        selectedColor = color
    }
}

extension ProductDetailsViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        if let placeOrderManager = placeOrderManager, let user = user {
            let cart = ATCShoppingCart()
            cart.addProduct(product: product,
                            vendorID: user.uid,
                            quantity: 1,
                            selectedColor: selectedColor,
                            selectedSize: selectedSize)
            placeOrderManager.placeOrder(user: user,
                                         address: convertApplePayAddressToAddress(shippingContact: payment.shippingContact),
                                         cart: cart, completion: {[weak self] (success) in
                guard let `self` = self else { return }
                controller.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            controller.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension ProductDetailsViewController {
    func convertApplePayAddressToAddress(shippingContact: PKContact?) -> ATCAddress {
        guard let shippingContact = shippingContact else { return ATCAddress() }
        return ATCAddress(name: shippingContact.name?.description,
                          line1: shippingContact.postalAddress?.street,
                          line2: shippingContact.postalAddress?.subLocality,
                          city: shippingContact.postalAddress?.city,
                          state: shippingContact.postalAddress?.state,
                          postalCode: shippingContact.postalAddress?.postalCode,
                          country: shippingContact.postalAddress?.country,
                          phone: shippingContact.phoneNumber?.stringValue,
                          email: shippingContact.emailAddress)
    }
}


extension ProductDetailsViewController: ProductImageDelegate {
    func didLoad(_ image: UIImage) {
        self.currentImage = image
    }
}

extension ProductDetailsViewController: SizeSelectorViewControllerDelegate {
    func sizeSelectorViewController(_ sizeSelectorViewController: SizeSelectorViewController, didSelect size: String) {
        selectedSize = size
    }
}

extension ProductDetailsViewController: CheckoutViewControllerDelegate {
    func checkoutViewController(_ vc: CheckoutViewController, didCompleteCheckout address: ATCAddress) {
        if let placeOrderManager = placeOrderManager {
            placeOrderManager.placeOrder(user: user, address: address, cart: payCart) {[weak self] (success) in
                guard let `self` = self else { return }
                if let webUrl = self.payCart.webUrl {
                }
            }
        }
    }
}
