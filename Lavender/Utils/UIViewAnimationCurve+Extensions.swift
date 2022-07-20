//
//  UIViewAnimationCurve+Extensions.swift
//  Lavender
//
//  Created by Van Muoi on 7/16/22.
//

import UIKit

public extension UIView.AnimationCurve {
    var animationOption: UIView.AnimationOptions {
        switch self {
        case .easeIn:
            return .curveEaseIn
        case .easeInOut:
            return UIView.AnimationOptions()
        case .easeOut:
            return .curveEaseOut
        case .linear:
            return .curveLinear
        @unknown default:
            return .curveEaseInOut
        }
    }
}

