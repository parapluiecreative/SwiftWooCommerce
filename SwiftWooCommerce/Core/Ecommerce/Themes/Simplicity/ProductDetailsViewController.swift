//
//  ProductDetailsViewController.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 11/18/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import Kingfisher
import UIKit

class ProductDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, StepperierDelegate {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var productTitleLabel: UILabel!
    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var addToCartButton: UIButton!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var stepperier: Stepperier!
    @IBOutlet weak var contentView: UIView!

    fileprivate let product: Product
    fileprivate var selectedCollectionItemIndexPath = IndexPath(row: 0, section: 0)
    fileprivate let uiConfig: ATCUIGenericConfigurationProtocol
    fileprivate let cartManager: ATCShoppingCartManager
    private let uiEcommerceConfig: ATCUIConfigurationProtocol
    
    init(product: Product,
         uiConfig: ATCUIGenericConfigurationProtocol,
         cartManager: ATCShoppingCartManager,
         nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         uiEcommerceConfig: ATCUIConfigurationProtocol) {
        self.product = product
        self.uiConfig = uiConfig
        self.cartManager = cartManager
        self.uiEcommerceConfig = uiEcommerceConfig
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = product.title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        populateContent()
    }

    fileprivate func configureUI() {
        collectionView.isPagingEnabled = true
        collectionView?.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = uiConfig.mainThemeBackgroundColor

        mainImageView.contentMode = .scaleAspectFit
        mainImageView.backgroundColor = uiEcommerceConfig.productDetailsScreenImageBackground

        productTitleLabel.font = uiEcommerceConfig.productDetailsTitleFont
        productTitleLabel.textColor = uiEcommerceConfig.productDetailsTextColor

        priceLabel.layer.borderColor = uiEcommerceConfig.productDetailsPriceBorderColor.cgColor
        priceLabel.layer.borderWidth = 1
        priceLabel.layer.cornerRadius = 5
        priceLabel.font = uiEcommerceConfig.productDetailsPriceFont
        priceLabel.textColor = uiEcommerceConfig.productDetailsTextColor
        priceLabel.backgroundColor = .clear

        addToCartButton.backgroundColor = uiEcommerceConfig.productDetailsAddToCartButtonBgColor
        addToCartButton.setTitleColor(.white, for: .normal)
        addToCartButton.layer.cornerRadius = 5
        addToCartButton.titleLabel?.font = uiEcommerceConfig.productDetailsAddToCartButtonFont
        addToCartButton.addTarget(self, action: #selector(didTapAddToCartButton), for: .touchUpInside)

        descriptionLabel.textColor = uiEcommerceConfig.productDetailsTextColor
        descriptionLabel.font = uiEcommerceConfig.productDetailsDescriptionFont
        descriptionLabel.backgroundColor = .clear

        stepperier.delegate = self
        stepperier.operationSymbolsColor = UIColor.black.darkModed
        stepperier.valueBackgroundColor = UIColor.white.darkModed
        stepperier.value = 1
        stepperier.tintColor = UIColor.black.darkModed

        stepperier.layer.borderWidth = 1
        stepperier.layer.cornerRadius = 10
        stepperier.layer.borderColor = uiEcommerceConfig.productDetailsPriceBorderColor.cgColor
        stepperier.font = uiEcommerceConfig.productDetailsStepperierFont

        self.contentView.backgroundColor = uiConfig.mainThemeBackgroundColor
        self.view.backgroundColor = uiConfig.mainThemeBackgroundColor
    }

    fileprivate func populateContent() {
        if let price = Double(product.price) {
            let totalPrice = price * Double(stepperier.value)
            priceLabel.text = NSString(format: "$%.2f", totalPrice) as String
        } else {
            priceLabel.text = "$" + product.price
        }
        productTitleLabel.text = product.title
        addToCartButton.setTitle("Add to Cart".localizedEcommerce, for: .normal)
        if let firstImageURLString = product.images.first {
            mainImageView.kf.setImage(with: URL(string: firstImageURLString))
        }
        descriptionLabel.text = product.productDescription
        stepperier.minimumValue = 1
    }

    @objc func didTapAddToCartButton() {
        if cartManager.cart.vendorID != nil {
            if product.vendorID != cartManager.cart.vendorID {
                showVendorChangeAlert()
                return
            }
        }
        didConfirmAddToCart()
    }

    func didConfirmAddToCart(reset: Bool = false) {
        if (reset) {
            cartManager.clearProducts()
        }
        cartManager.setProduct(product: product,
                               vendorID: product.vendorID,
                               vendor: product.vendor,
                               quantity: stepperier.value)

        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true) {}
    }

    fileprivate func showVendorChangeAlert() {
        let controller = UIAlertController(title: "Reset shopping cart?".localizedEcommerce, message: "You can only order from a single vendor per transaction. Your previous items will be removed from the cart.".localizedEcommerce, preferredStyle: .alert)
        let addToCartAction = UIAlertAction(title: "Add to Cart".localizedEcommerce, style: .destructive) { [weak self] (camera) in
            guard let `self` = self else { return }
            self.didConfirmAddToCart(reset: true)
        }

        let cancelAction = UIAlertAction(title: "Cancel".localizedCore, style: .cancel, handler: nil)

        controller.addAction(addToCartAction)
        controller.addAction(cancelAction)

        present(controller, animated: true, completion: nil)
    }
}

extension ProductDetailsViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        mainImageView.kf.setImage(with: URL(string: product.images[indexPath.row]))
        selectedCollectionItemIndexPath = indexPath
        collectionView.reloadData()
    }
}

extension ProductDetailsViewController {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return product.images.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath)
        if let imageCell = cell as? ImageCollectionViewCell  {
            imageCell.backgroundImageView.kf.setImage(with: URL(string: product.images[indexPath.row]))
            imageCell.configure(isSelected: (indexPath == selectedCollectionItemIndexPath), uiEcommerceConfig: uiEcommerceConfig)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return uiEcommerceConfig.productDetailsCollectionViewCellSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension ProductDetailsViewController {
    func steperrier(_ steperrier: Stepperier, didUpdateValueTo value: Int) {
        self.populateContent()
    }
}
