//
//  CommentInputTextView.swift
//  Lavender
//
//  Created by Van Muoi on 7/3/22.
//

import UIKit

class CommentInputTextView: UITextView, UITextViewDelegate {
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter comment.."
        label.textColor = .lightGray
        return label
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        addSubview(placeholderLabel)
        
        delegate = self
        
        placeholderLabel.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = true
    }
//
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        placeholderLabel.isHidden = true
//    }
    
}
