//
//  MainTabVC.swift
//  Lavender
//
//  Created by Van Muoi on 5/14/22.
//

import UIKit
import Firebase

class MainTabVC: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: Properties
    
    let dot = UIView()
    var notificationIDs = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegate
        self.delegate = self
        
        configViewControllers()
        
        configNotificationDot()
        
        observeNotifications()
        
        checkIfUserIsLoggedIn() 
    }
    
    func configViewControllers() {
        let feedVC = configureNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: FeedVC(collectionViewLayout: UICollectionViewFlowLayout()))
        let searchVC = configureNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: SearchVC())
        let profileVC = configureNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
        let notificationsVC = configureNavController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"), rootViewController: NotificationsVC())
        let uploadPostVC = configureNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
        
        viewControllers = [feedVC, searchVC, uploadPostVC, notificationsVC, profileVC]
        tabBar.tintColor = .black
    }
    
    func configNotificationDot() {
        
        if UIDevice().userInterfaceIdiom == .phone {
            
            let tabBarHeight = tabBar.frame.height
            
            
            if UIScreen.main.nativeBounds.height == 2532 {
                // handle for iphone 12
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - tabBarHeight, width: 6, height: 6)
            } else {
                // handle for iphone old version < iphone X
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - 16, width: 6, height: 6)
            }
            
            // create dot
            dot.center.x = (view.frame.width / 5 * 3 + (view.frame.width / 5) / 2)
            dot.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1)
            dot.layer.cornerRadius = dot.frame.width / 2
            self.view.addSubview(dot)
            dot.isHidden = true
        }
    }
    
    // MARK: UITabBarController
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = tabBarController.viewControllers?.firstIndex(of: viewController)
        if index == 2 {
            let selectImageVC = SelectImageVC(collectionViewLayout: UICollectionViewFlowLayout())
            let navController = UINavigationController(rootViewController: selectImageVC)
            navController.navigationBar.tintColor = .black
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true, completion: nil)
            return false
        } else if index == 3 {
            dot.isHidden = true
            return true
        }
        return true
    }
    
    func configureNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.tintColor = .black
        return navController
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginVC = LoginVC()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
    }
    
    func observeNotifications() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        self.notificationIDs.removeAll()
        
        NOTIFICATIONS_REF.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.forEach { snapshot in
                
                let notificationId = snapshot.key
                
                NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").observeSingleEvent(of: .value, with: { snapshot in
                    guard let checked = snapshot.value as? Int else { return }
                    
                    if checked == 0 {
                        self.dot.isHidden = false
                    }
                })
            }
        }
    }
}
