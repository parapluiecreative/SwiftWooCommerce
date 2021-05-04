//
//  InputBarRecordItem.swift
//  
//

import UIKit

/**
 A InputItem that inherits from UIButton
 
 ## Important Notes ##
 1. Intended to be used in an `InputStackView`
 */
open class InputBarRecordItem: UIView, InputItem {
    
    /// The spacing properties of the InputBarButtonItem
    ///
    /// - fixed: The spacing is fixed
    /// - flexible: The spacing is flexible
    /// - none: There is no spacing
    public enum Spacing {
        case fixed(CGFloat)
        case flexible
        case none
    }
    
    public typealias InputBarButtonItemAction = ((InputBarButtonItem) -> Void)
    
    // MARK: - Properties
    
    /// A weak reference to the InputBarAccessoryView that the InputBarButtonItem used in
    open weak var inputBarAccessoryView: InputBarAccessoryView?
    
    open var timerLabel: UILabel!
    open var recordButton: UIButton!
    open var cancelButton: UIButton!
    open var sendButton: UIButton!
    open var stackView: UIStackView!
    
    var recodingDelegate: ATCChatAudioRecordingProtocol?
    var uiConfig: ATCChatUIConfigurationProtocol?
    /// The spacing property of the InputBarButtonItem that determines the contentHuggingPriority and any
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
    private var size: CGSize? = CGSize(width: 100, height: 100) {
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
    
    /// A reference to the stack view position that the InputBarButtonItem is held in
    open var parentStackViewPosition: InputStackView.Position?
        
    // MARK: - Reactive Hooks
    
    private var onTouchUpInsideAction: InputBarButtonItemAction?
    private var onKeyboardEditingBeginsAction: InputBarButtonItemAction?
    private var onKeyboardEditingEndsAction: InputBarButtonItemAction?
    private var onKeyboardSwipeGestureAction: ((InputBarButtonItem, UISwipeGestureRecognizer) -> Void)?
    private var onTextViewDidChangeAction: ((InputBarButtonItem, InputTextView) -> Void)?
    private var onSelectedAction: InputBarButtonItemAction?
    private var onDeselectedAction: InputBarButtonItemAction?
    private var onEnabledAction: InputBarButtonItemAction?
    private var onDisabledAction: InputBarButtonItemAction?
    
    // MARK: - Initialization
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Setup
    
    /// Sets up the default properties
    open func setup() {
        setContentHuggingPriority(UILayoutPriority(rawValue: 500), for: .horizontal)
        setContentHuggingPriority(UILayoutPriority(rawValue: 500), for: .vertical)
        timerLabel = UILabel()
        self.addSubview(timerLabel)
        self.tintColor = uiConfig?.primaryColor
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = timerLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        let verticalConstraint = timerLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        verticalConstraint.constant = verticalConstraint.constant - 20
        self.addConstraints([horizontalConstraint,verticalConstraint])
        timerLabel.textAlignment = .center
        timerLabel.font = uiConfig?.fontAudioTimerLabel
        timerLabel.textColor = uiConfig?.audioTimerTextColor
        timerLabel.text = "0:00"
        
        recordButton = UIButton()
        recordButton.layer.cornerRadius = 8
        recordButton.addTarget(
            self,
            action: #selector(recordButtonPressed),
            for: .touchUpInside)
        self.addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        let leadingConstraint = recordButton.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let trailingConstraint = recordButton.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        let bottomConstraint = recordButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        let recordButtonHeightConstraint = recordButton.heightAnchor.constraint(equalToConstant: 50)
        self.addConstraints([leadingConstraint,
                         trailingConstraint,
                         bottomConstraint,
                         recordButtonHeightConstraint])
        recordButton.backgroundColor = UIColor.red
        recordButton.setTitle("Record".localizedThirdParty, for: .normal)
                
        cancelButton = UIButton()
        cancelButton.layer.cornerRadius = 8
        cancelButton.addTarget(
            self,
            action: #selector(cancelButtonPressed),
            for: .touchUpInside)
        cancelButton.backgroundColor = UIColor.lightGray
        cancelButton.setTitle("Cancel".localizedCore, for: .normal)
        
        sendButton = UIButton()
        sendButton.layer.cornerRadius = 8
        sendButton.addTarget(
            self,
            action: #selector(sendButtonPressed),
            for: .touchUpInside)
        sendButton.backgroundColor = UIColor.lightGray
        sendButton.setTitle("Send".localizedThirdParty, for: .normal)

        stackView = UIStackView()
        self.addSubview(stackView)
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(sendButton)
        stackView.spacing = 10
        stackView.distribution = .fillEqually

        stackView.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        let stackViewLeadingConstraint = stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let stackViewTrailingConstraint = stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        let stackViewBottomConstraint = stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        
        let cancelButtonHeightConstraint = cancelButton.heightAnchor.constraint(equalToConstant: 50)
        self.addConstraints([
            stackViewLeadingConstraint,
            stackViewTrailingConstraint,
            stackViewBottomConstraint,
            cancelButtonHeightConstraint])
        
        stackView.isHidden = true

    }
    
    // MARK: - Button Actions
    
    @objc private func recordButtonPressed() {
        recordButton.isHidden = true
        stackView.isHidden = false
        recodingDelegate?.startAudioRecord()
    }
    
    @objc private func cancelButtonPressed() {
        recordButton.isHidden = false
        stackView.isHidden = true
        recodingDelegate?.cancelAudioRecord()
    }
    
    @objc private func sendButtonPressed() {
        recordButton.isHidden = false
        stackView.isHidden = true
        recodingDelegate?.sendAudioRecord()
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
    
    // MARK: - Hook Setup Methods
        
    /// Sets the onKeyboardEditingBeginsAction
    ///
    /// - Parameter action: The new onKeyboardEditingBeginsAction
    /// - Returns: Self
    @discardableResult
    open func onKeyboardEditingBegins(_ action: @escaping InputBarButtonItemAction) -> Self {
        onKeyboardEditingBeginsAction = action
        return self
    }
    
    /// Sets the onKeyboardEditingEndsAction
    ///
    /// - Parameter action: The new onKeyboardEditingEndsAction
    /// - Returns: Self
    @discardableResult
    open func onKeyboardEditingEnds(_ action: @escaping InputBarButtonItemAction) -> Self {
        onKeyboardEditingEndsAction = action
        return self
    }
    
    
    /// Sets the onKeyboardSwipeGestureAction
    ///
    /// - Parameter action: The new onKeyboardSwipeGestureAction
    /// - Returns: Self
    @discardableResult
    open func onKeyboardSwipeGesture(_ action: @escaping (_ item: InputBarButtonItem, _ gesture: UISwipeGestureRecognizer) -> Void) -> Self {
        onKeyboardSwipeGestureAction = action
        return self
    }
    
    /// Sets the onTextViewDidChangeAction
    ///
    /// - Parameter action: The new onTextViewDidChangeAction
    /// - Returns: Self
    @discardableResult
    open func onTextViewDidChange(_ action: @escaping (_ item: InputBarButtonItem, _ textView: InputTextView) -> Void) -> Self {
        onTextViewDidChangeAction = action
        return self
    }
    
    /// Sets the onTouchUpInsideAction
    ///
    /// - Parameter action: The new onTouchUpInsideAction
    /// - Returns: Self
    @discardableResult
    open func onTouchUpInside(_ action: @escaping InputBarButtonItemAction) -> Self {
        onTouchUpInsideAction = action
        return self
    }
    
    /// Sets the onSelectedAction
    ///
    /// - Parameter action: The new onSelectedAction
    /// - Returns: Self
    @discardableResult
    open func onSelected(_ action: @escaping InputBarButtonItemAction) -> Self {
        onSelectedAction = action
        return self
    }
    
    /// Sets the onDeselectedAction
    ///
    /// - Parameter action: The new onDeselectedAction
    /// - Returns: Self
    @discardableResult
    open func onDeselected(_ action: @escaping InputBarButtonItemAction) -> Self {
        onDeselectedAction = action
        return self
    }
    
    /// Sets the onEnabledAction
    ///
    /// - Parameter action: The new onEnabledAction
    /// - Returns: Self
    @discardableResult
    open func onEnabled(_ action: @escaping InputBarButtonItemAction) -> Self {
        onEnabledAction = action
        return self
    }
    
    /// Sets the onDisabledAction
    ///
    /// - Parameter action: The new onDisabledAction
    /// - Returns: Self
    @discardableResult
    open func onDisabled(_ action: @escaping InputBarButtonItemAction) -> Self {
        onDisabledAction = action
        return self
    }
    
    // MARK: - InputItem Protocol
    
    /// Executes the onTextViewDidChangeAction with the given textView
    ///
    /// - Parameter textView: A reference to the InputTextView
    open func textViewDidChangeAction(with textView: InputTextView) {
    }
    
    /// Executes the onKeyboardSwipeGestureAction with the given gesture
    ///
    /// - Parameter gesture: A reference to the gesture that was recognized
    open func keyboardSwipeGestureAction(with gesture: UISwipeGestureRecognizer) {
    }
    
    /// Executes the onKeyboardEditingEndsAction
    open func keyboardEditingEndsAction() {
    }
    
    /// Executes the onKeyboardEditingBeginsAction
    open func keyboardEditingBeginsAction() {
    }
    
    /// Executes the onTouchUpInsideAction
    @objc
    open func touchUpInsideAction() {
    }
    
    // MARK: - Static Spacers
    
    /// An InputBarButtonItem that's spacing property is set to be .flexible
    public static var flexibleSpace: InputBarButtonItem {
        let item = InputBarButtonItem()
        item.setSize(.zero, animated: false)
        item.spacing = .flexible
        return item
    }
    
    /// An InputBarButtonItem that's spacing property is set to be .fixed with the width arguement
    public static func fixedSpace(_ width: CGFloat) -> InputBarButtonItem {
        let item = InputBarButtonItem()
        item.setSize(.zero, animated: false)
        item.spacing = .fixed(width)
        return item
    }
}
