//
//  CommentCell.swift
//  Lavender
//
//  Created by Van Muoi on 6/19/22.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    var comment: Comment? {
        didSet {
            
            guard let user = comment?.user,
                  let profileImageUrl = user.profileImage,
                  let username = user.username,
                  let commentText = comment?.commentText else { return }
            
            self.profileImageView.loadImage(with: profileImageUrl)
            
            let attributedText = NSMutableAttributedString(string: "\(username)", attributes: [NSMutableAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
            attributedText.append(NSAttributedString(string: " \(commentText)", attributes: [NSMutableAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
            
            attributedText.append(NSAttributedString(string: " 2d", attributes: [NSMutableAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            
            self.commentTextView.attributedText = attributedText
            
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    let commentTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 12)
        tv.isScrollEnabled = false
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 40/2
        
        addSubview(commentTextView)
        
        commentTextView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4 , width: 0, height: 0)
        commentTextView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
//        addSubview(separatorView)
//        separatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 60, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
