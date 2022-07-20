//
//  NotificationCell.swift
//  Lavender
//
//  Created by Van Muoi on 6/22/22.
//

import Foundation
import UIKit

class NotificationCell: UITableViewCell {
    
    // MARK: Properties
    
    var delegate: NotificationCellDelegate?
    
    var notification: NotificationModel? {
        didSet {
            
            configureNotificationLabel()
            
            configureNotificationType()
            
            if let post = notification?.post {
                postImageView.loadImage(with: post.imageUrl)
            }
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let notificationLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.rgbPrimary()
        button.layer.cornerRadius = 3
        button.setTitle("Follow", for: .normal)
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var postImageView: CustomImageView = {
       let image = CustomImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .lightGray
        let postTap = UITapGestureRecognizer(target: self, action: #selector(handlePostTapped))
        image.addGestureRecognizer(postTap)
        image.isUserInteractionEnabled = true
        return image
    }()
    
    // MARK: Handler
    
    @objc func handleFollowTapped() {
        delegate?.handleFollowTapped(for: self)
    }
    
    @objc func handlePostTapped() {
        delegate?.handlePostTapped(for: self)
    }
    
    func configureNotificationType() {
        guard let notification = self.notification,
              let user = notification.user else { return }

        if let profileImageUrl = user.profileImage, profileImageUrl != "" {
            self.profileImageView.loadImage(with: profileImageUrl)
        } else {
            self.profileImageView.image = UIImage(named: "user_default")
        }
        
        if notification.notificationType != .Follow {
            // notification type is comment or like
            addSubview(postImageView)
            postImageView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 40, height: 40)
            
        } else {
            // notification type is follow
            addSubview(followButton)
            followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 90, height: 30)
            followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            
            user.checkIfUserIsFollowed(completion: { followed in
                
                if followed {
                    self.followButton.setTitle("Following", for: .normal)
                    self.followButton.setTitleColor(.black, for: .normal)
                    self.followButton.layer.borderWidth = 0.5
                    self.followButton.layer.borderColor = UIColor.lightGray.cgColor
                    self.followButton.backgroundColor = UIColor.rgbPrimary()
                } else {
                    self.followButton.setTitle("Follow", for: .normal)
                    self.followButton.setTitleColor(.white, for: .normal)
                    self.followButton.layer.borderWidth = 0
                    self.followButton.backgroundColor = UIColor.rgbPrimary()
                }
            })
            
        }
        
        addSubview(notificationLabel)
        notificationLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4 , width: 0, height: 0)
        notificationLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    
    func configNotificationTimeStamp() -> String? {
        guard let notification = self.notification else { return nil }
        
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        dateFormatter.maximumUnitCount = 1
        dateFormatter.unitsStyle = .abbreviated
        
        let now = Date()
        let dateToDisplay = dateFormatter.string(from: notification.creationDate, to: now)
        guard let dateToDisplay = dateToDisplay else { return nil }
        return " \(String(describing: dateToDisplay))"
    }
    
    func configureNotificationLabel() {
        
        guard let user = notification?.user,
              let username = user.username,
              let notificationMessage = notification?.notificationType.description,
              let notificationTimeStamp = configNotificationTimeStamp() else { return }
        
        let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: notificationMessage, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        
        attributedText.append(NSAttributedString(string: notificationTimeStamp, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        notificationLabel.attributedText = attributedText
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 40/2

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
