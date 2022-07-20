//
//  KeyboardAnimationInfo.swift
//  Lavender
//
//  Created by Van Muoi on 7/16/22.
//

import UIKit

public struct KeyboardAnimationInfo {
    public let duration: Double
    public let animationOption: UIView.AnimationOptions
    public let endFrameRect: CGRect
    public static func from(notification: Notification) -> KeyboardAnimationInfo? {
        guard let info = notification.userInfo, let endFrameInfo = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue, let animationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, let keyboardAnimationCurve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else { return nil }

        return KeyboardAnimationInfo(duration: animationDuration.doubleValue, animationOption: keyboardAnimationCurve.animationOption, endFrameRect: endFrameInfo.cgRectValue)
    }
}

private extension NSNumber {
    var animationOption: UIView.AnimationOptions {
        var curveValue = intValue
        if curveValue > UIView.AnimationCurve.linear.rawValue { curveValue = UIView.AnimationCurve.easeInOut.rawValue }
        return UIView.AnimationCurve(rawValue: curveValue)?.animationOption ?? []
    }
}

