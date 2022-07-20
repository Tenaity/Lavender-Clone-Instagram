//
//  UIView+Extensions.swift
//  Lavender
//
//  Created by Van Muoi on 7/16/22.
//

import Foundation
import UIKit

public extension UIView {
    class func viewFromNibForClass<T>(owner: UIView? = nil, nibName: String = String(describing: T.self), bundle: Foundation.Bundle? = nil) -> T {
        let nib = UINib(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: owner, options: nil)[0] as? T else {
            fatalError("no nib for class named \(nibName)")
        }
        return view
    }
    
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

