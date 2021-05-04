//
//  ReplyItemView.swift
//  ChatApp
//
//  Created by Duy Bui on 9/2/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit

protocol ReplyItemDelegate: class {
    func didTapOnCloseButton()
}

class ReplyItemView: UIView, InputItem {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var recipientsLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    weak var delegate: ReplyItemDelegate?
    
    @IBAction func didTapOnCancelButton(_ sender: Any) {
        delegate?.didTapOnCloseButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commitInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commitInit()
    }
    
    private func commitInit() {
        Bundle.main.loadNibNamed("ReplyItemView",
                                 owner: self,
                                 options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        setContentHuggingPriority(UILayoutPriority(rawValue: 500), for: .horizontal)
        setContentHuggingPriority(UILayoutPriority(rawValue: 500), for: .vertical)
    }
    
    func configure(with recipient: String?, content: String?) {
        contentLabel.text = content
        recipientsLabel.text = recipient
    }
    
    // MARK: - Size Adjustment
    
    /// Sets the size of the InputBarButtonItem which overrides the intrinsicContentSize. When set to nil
    /// the default intrinsicContentSize is used. The new size will be laid out in the UIStackView that
    /// the InputBarButtonItem is held in
    ///
    /// - Parameters:
    ///   - newValue: The new size
    ///   - animated: If the layout should be animated
    open func setSize(_ newValue: CGSize?, animated: Bool) {
        size = newValue
        if animated, let position = parentStackViewPosition {
            inputBarAccessoryView?.performLayout(animated) { [weak self] in
                self?.inputBarAccessoryView?.layoutStackViews([position])
            }
        }
    }
    
    // The spacing properties of the InputBarButtonItem
    ///
    /// - fixed: The spacing is fixed
    /// - flexible: The spacing is flexible
    /// - none: There is no spacing
    public enum Spacing {
        case fixed(CGFloat)
        case flexible
        case none
    }

    /// additional space to the intrinsicContentSize
    open var spacing: Spacing = .none {
        didSet {
            switch spacing {
            case .flexible:
                setContentHuggingPriority(UILayoutPriority(rawValue: 1), for: .horizontal)
            case .fixed:
                setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
            case .none:
                setContentHuggingPriority(UILayoutPriority(rawValue: 500), for: .horizontal)
            }
        }
    }
    
    /// When not nil this size overrides the intrinsicContentSize
       private var size: CGSize? = CGSize(width: 100, height: 60) {
           didSet {
               invalidateIntrinsicContentSize()
           }
       }
       
       open override var intrinsicContentSize: CGSize {
           var contentSize = size ?? super.intrinsicContentSize
           switch spacing {
           case .fixed(let width):
               contentSize.width += width
           case .flexible, .none:
               break
           }
           return contentSize
       }
    
    // MARK: - Conform required functions of InputItem
    var inputBarAccessoryView: InputBarAccessoryView?
    
    var parentStackViewPosition: InputStackView.Position?
    
    func textViewDidChangeAction(with textView: InputTextView) {}
    
    func keyboardSwipeGestureAction(with gesture: UISwipeGestureRecognizer) {}
    
    func keyboardEditingEndsAction() {}
    
    func keyboardEditingBeginsAction() {}
}
