//
//  NoInternetConnectionView.swift
//  Lavender
//
//  Created by Van Muoi on 7/16/22.
//

import Foundation
import UIKit

public struct NoInternetContent: SnackbarContent {
    public var message: String
    
    public var buttonTitle: String?
    
    public var duration: SnackbarDuration?
    
    public var animationDuration: TimeInterval?
    
    public init(message: String, buttonTitle: String? = nil, duration: SnackbarDuration? = nil, animationDuration: TimeInterval? = nil) {
        self.message = message
        self.buttonTitle = buttonTitle
        self.duration = duration
        self.animationDuration = animationDuration
    }
}

public class NoInternetConnectionView: SnackbarView {
    
    override public var viewTag: Int {
        return 6969
    }
    
    public static var noInternetActionBlock: (() -> Void)?
    
    public override func show(content: SnackbarContent? = nil, contentInsets: ContentInsets = .default, theme: Theme = .default, force: Bool = false, callback: (() -> Void)? = nil) {
        super.show(content: content, contentInsets: contentInsets, theme: theme, force: true, callback: callback)
        if callback != nil {
            NoInternetConnectionView.noInternetActionBlock = callback
        }
        SnackbarView.actionBlock = NoInternetConnectionView.noInternetActionBlock
    }
    
    public override func hide() {
        super.hide()
    }

    public func showIfNeeded(content: NoInternetContent) {
        guard !NetworkReachability.isReachable else { return }
        show(content: content, force: true)
    }
}

