//
//  ATCFormTextFieldAdapter.swift
//  ListingApp
//
//  Created by Florian Marcu on 10/6/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCFormTextViewAdapter: NSObject, ATCGenericCollectionRowAdapter {
    let uiConfig: ATCUIGenericConfigurationProtocol
    let height: CGFloat

    init(uiConfig: ATCUIGenericConfigurationProtocol, height: CGFloat) {
        self.height = height
        self.uiConfig = uiConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        if let _ = object as? ATCFormTextFieldViewModel, let cell = cell as? ATCFormTextFieldCollectionViewCell {
            cell.textView.delegate = cell.textView
            cell.textView.font = uiConfig.regularLargeFont
            cell.containerView.backgroundColor = uiConfig.hairlineColor
            cell.hairlineView.backgroundColor = uiConfig.hairlineColor
            cell.topHairlineView.backgroundColor = uiConfig.hairlineColor
            cell.textView.atcPlaceholder = "Start typing...".localizedCore
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
        }
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCFormTextFieldCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        return CGSize(width: containerBounds.width, height: height)
    }
}

extension UITextView: UITextViewDelegate
{

    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }

    /// The UITextView placeholder text
    public var atcPlaceholder: String? {
        get {
            var placeholderText: String?

            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }

            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }

    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.count > 0
        }
    }

    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height + 2.0

            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }

    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()

        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()

        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100

        placeholderLabel.isHidden = self.text.count > 0

        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
}
