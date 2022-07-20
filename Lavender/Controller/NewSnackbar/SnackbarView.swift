//
//  SnackbarView.swift
//  Lavender
//
//  Created by Van Muoi on 7/16/22.
//

import Foundation
import UIKit

public protocol SnackbarContent {
    var message: String { get }
    var buttonTitle: String? { get }
    var duration: SnackbarDuration? { get }
    var animationDuration: TimeInterval? { get }
}

public enum SnackbarDuration {
    case fixedTime(second: Int)
    case forever
    
    var durationToShow: Int {
        switch self {
        case .forever:
            return -1 // Keep to show forever
        case .fixedTime(let duration):
            return duration
        }
    }
}

public struct GeneralSnackbarContent: SnackbarContent {
    public var message: String
    public var buttonTitle: String?
    public var duration: SnackbarDuration?
    public var animationDuration: TimeInterval?
    public init(message: String,
                buttonTitle: String? = nil,
                duration: SnackbarDuration? = .fixedTime(second: 5)) {
        self.message = message
        self.buttonTitle = buttonTitle
        self.duration = duration
    }
}

open class SnackbarView: UIView {
    
    public struct Tags {
        static let `default` = 6968
    }

    public struct ContentInsets {

        public let top: CGFloat
        public let left: CGFloat
        public let right: CGFloat

        public init(top: CGFloat, left: CGFloat, right: CGFloat) {
            self.top = top
            self.left = left
            self.right = right
        }

    }

    public struct Theme {

        public let buttonColor: UIColor
        public let messageColor: UIColor
        public let backgroundColor: UIColor

        public init(buttonColor: UIColor, messageColor: UIColor, backgroundColor: UIColor) {
            self.buttonColor = buttonColor
            self.messageColor = messageColor
            self.backgroundColor = backgroundColor
        }

    }
    
    open var viewTag: Int { Tags.default }
    
    @IBOutlet private weak var contentViewSnackbar: UIView!

    @IBOutlet private weak var messageLabel: UITextField!
    
//    @IBOutlet private weak var leadingInset: NSLayoutConstraint!
//    @IBOutlet private weak var topInset: NSLayoutConstraint!
//    
//    @IBOutlet private weak var trailingInset: NSLayoutConstraint!
//    @IBOutlet private weak var messageLabelTrailingConstraint: NSLayoutConstraint!
//    @IBOutlet private weak var actionButtonLeadingConstraint: NSLayoutConstraint!
    
    /// Constraints.
    private var leftMarginConstraint: NSLayoutConstraint?
    private var rightMarginConstraint: NSLayoutConstraint?
    private var bottomMarginConstraint: NSLayoutConstraint?
    private var centerXConstraint: NSLayoutConstraint?
    
    /// Snackbar min height
    private static var snackbarMinHeight: CGFloat = 60
    
    // Action block when tapping on button
    public static var actionBlock: (() -> Void)?
    
    // Snackbar content to display
    private var content: SnackbarContent?
    
    /// Snackbar display duration. Default keep it forever.
    private var duration: SnackbarDuration = .forever
    
    /// Show and hide animation duration. Default is 0.8
    private var animationDuration: TimeInterval = 0.8
    
    /// Bottom margin. Default is 0
    private var bottomMargin: CGFloat = 0 {
        didSet {
            bottomMarginConstraint?.constant = -bottomMargin
            superview?.layoutIfNeeded()
        }
    }
    
    /// Timer to dismiss the snackbar.
    private var dismissTimer: Timer?
    
    /// Keyboard mark
    private var keyboardHeight: CGFloat = 0
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Observer
        addObserver()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addObserver() {
        // Notification
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    open func show(content: SnackbarContent? = nil,
                   contentInsets: ContentInsets = .default,
                   theme: Theme = .default,
                   force: Bool = false,
                   callback: (() -> Void)? = nil) {

        if callback != nil {
            SnackbarView.actionBlock = callback
        }
        let view = getCurrentViewFromWindow(viewTag: viewTag)
        if force || view == nil {
            view?.dismiss()
            
            let newView: SnackbarView = .viewFromNibForClass(owner: self, nibName: String(describing: SnackbarView.self), bundle: nil)
            newView.tag = viewTag
            newView.update(theme: theme)
            newView.update(contentInsets: contentInsets)
            if let content = content {
                newView.update(content: content)
            }
            newView.showOnCurrentWindow()
        }
    }
    
    open func hide() {
        getCurrentViewFromWindow(viewTag: viewTag)?.dismiss()
    }
}

// MARK: - Show and dismiss methods.
private extension SnackbarView {
    
    func update(content: SnackbarContent) {
        messageLabel.text = content.message

        self.duration = content.duration ?? .forever
        self.animationDuration = content.animationDuration ?? 0.8
    }

    func update(contentInsets: ContentInsets) {

    }

    func update(theme: Theme) {
        contentViewSnackbar.backgroundColor = UIColor.rgbPrimary()
        messageLabel.textColor = theme.messageColor
    }
    
    func showOnCurrentWindow() {
        guard let window = UIApplication.shared.delegate?.window ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        createDismissTimer()
        window.addSubview(self)
        
        // Update constraints
        updateConstraintsToShow(on: window)
        
        // Show
        showWithAnimation()
    }
    
    func updateConstraintsToShow(on window: UIWindow) {
        // Left & Right margin constraint
        if #available(iOS 11.0, *) {
            leftMarginConstraint = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: window.safeAreaLayoutGuide, attribute: .left, multiplier: 1, constant: 0)
            rightMarginConstraint = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: window.safeAreaLayoutGuide, attribute: .right, multiplier: 1, constant: 0)
        } else {
            leftMarginConstraint = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: window, attribute: .left, multiplier: 1, constant: 0)
            rightMarginConstraint = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: window, attribute: .right, multiplier: 1, constant: 0)
        }
        
        // Bottom margin constraint
        bottomMarginConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: window, attribute: .bottom, multiplier: 1, constant: 0)
        
        // Center X constraint
        centerXConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: window, attribute: .centerX, multiplier: 1, constant: 0)
        
        // Add constraints
        window.addConstraint(leftMarginConstraint!)
        window.addConstraint(rightMarginConstraint!)
        window.addConstraint(bottomMarginConstraint!)
        window.addConstraint(centerXConstraint!)
    }
    
    /// Dismiss the snackbar manually.
    @objc func dismiss() {
        DispatchQueue.main.async {
            self.dismissAnimated(true)
        }
    }
}

// MARK: - Dismiss methods.
private extension SnackbarView {
    
    func getCurrentViewFromWindow(viewTag: Int) -> SnackbarView? {
        guard let window = UIApplication.shared.delegate?.window ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        return window.subviews.first(where: { $0.tag == viewTag }) as? SnackbarView
    }

    func showWithAnimation() {
        let superViewWidth = (superview?.frame)!.width
        let snackbarHeight = systemLayoutSizeFitting(CGSize(width: superViewWidth, height: SnackbarView.snackbarMinHeight)).height
        // Update init state
        bottomMarginConstraint?.constant = snackbarHeight
        centerXConstraint?.constant = 0
        superview?.layoutIfNeeded()
        
        // Final state
        // Detect default bottom margin if keyboard already shown before NoInternetView initialised
        if UIApplication.shared.isKeyboardPresented {
            bottomMargin = max(keyboardHeight, bottomMargin)
        }
        bottomMarginConstraint?.constant = -bottomMargin
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveLinear, animations: {
            self.superview?.layoutIfNeeded()
        }, completion: nil)
    }
    
    func dismissAnimated(_ animated: Bool) {
        invalidDismissTimer()
        
        let snackbarHeight = frame.size.height
        var safeAreaInsets: UIEdgeInsets
        
        if #available(iOS 11.0, *) {
            safeAreaInsets = self.superview?.safeAreaInsets ?? .zero
        } else {
            safeAreaInsets = .zero
        }
        
        if !animated {
            removeFromSuperview()
            return
        }
        bottomMarginConstraint?.constant = snackbarHeight + safeAreaInsets.bottom
        setNeedsLayout()
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseIn, animations: {
            self.superview?.layoutIfNeeded()
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
    
    /// Create new dismiss timer
    func createDismissTimer() {
        guard duration.durationToShow > 0 else {
            return invalidDismissTimer()
        }
        let interval = TimeInterval(duration.durationToShow)
        dismissTimer = Timer(timeInterval: interval,
                                  target: self, selector: #selector(dismiss), userInfo: nil, repeats: false)
        RunLoop.main.add(dismissTimer!, forMode: .common)
    }

    /// Invalidate the dismiss timer.
    func invalidDismissTimer() {
        dismissTimer?.invalidate()
        dismissTimer = nil
    }
}

// MARK: - IBActions
private extension SnackbarView {

    @IBAction private func onTappedButton(_ sender: UIButton) {
        SnackbarView.actionBlock?()
    }
}

// MARK: - Keyboard notification
private extension SnackbarView {
    
    @objc func onKeyboardShow(_ notification: Notification) {
        guard let info = KeyboardAnimationInfo.from(notification: notification) else { return }
        keyboardHeight = info.endFrameRect.height
        bottomMargin = keyboardHeight
        UIView.animate(withDuration: info.duration) {
            self.superview?.layoutIfNeeded()
        }
    }
    
    @objc func onKeyboardHide(_ notification: Notification) {
        guard let info = KeyboardAnimationInfo.from(notification: notification) else { return }
        bottomMargin = 0
        UIView.animate(withDuration: info.duration) {
            self.superview?.layoutIfNeeded()
        }
    }
}

extension SnackbarView.ContentInsets {
    public static let `default`: SnackbarView.ContentInsets = .init(top: 15, left: 15, right: 15)
}

extension SnackbarView.Theme {
    public static let `default`: SnackbarView.Theme = .init(buttonColor: .white, messageColor: .white, backgroundColor: UIColor.rgbPrimary())
}

extension UIApplication {
    var isKeyboardPresented: Bool {
        guard let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow"), self.windows.contains(where: { $0.isKind(of: keyboardWindowClass) }) else { return false }
        return true
    }
}
