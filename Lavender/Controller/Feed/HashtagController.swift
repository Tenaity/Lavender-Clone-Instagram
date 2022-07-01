//
//  HashtagController.swift
//  Lavender
//
//  Created by Van Muoi on 7/1/22.
//

import Foundation
import UIKit
import Firebase

class HashtagController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: Properties
    
    var posts = [Post]()
    var hashtag: String?
    var mention: String?
    
    // MARK: Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigationBar()
        collectionView.register(HashtagCell.self, forCellWithReuseIdentifier: "HashtagCell")
        fetchPosts()
    }
    
    // MARK: UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.viewSinglePost = true
        feedVC.post = posts[indexPath.row]
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HashtagCell", for: indexPath) as! HashtagCell
        cell.post = posts[indexPath.row]
        return cell
    }
    
    // MARK: Handlers
    
    func configNavigationBar() {
        if let hashtag = hashtag {
            navigationItem.title = hashtag
        } else if let mention = mention {
            navigationItem.title = mention
        }
        
    }
    
    func fetchPosts() {
        
        guard let hashtag = hashtag else { return }
        
        HASHTAG_POST_REF.child(hashtag).observe(.childAdded) { snapshot in
            
            let postId = snapshot.key
            
            Database.fetchPost(with: postId, completion: { post in
                self.posts.append(post)
                self.collectionView.reloadData()
            })
        }
    }
}
