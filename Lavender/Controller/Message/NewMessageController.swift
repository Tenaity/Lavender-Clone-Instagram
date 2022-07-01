//
//  NewMessageController.swift
//  Lavender
//
//  Created by Van Muoi on 6/29/22.
//

import Foundation
import UIKit
import Firebase

private let reuseIdentifer = "NewMessageCell"

class NewMessageController: UITableViewController {
    
    // MARK: Properties
    
    var users = [User]()
    var messageController: MessageController?
    
    // MARK: Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(NewMessageCell.self, forCellReuseIdentifier: reuseIdentifer)
        
        configNavigationBar()
    
        fetchUser()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! NewMessageCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messageController?.showChatController(for: user)
        }
    }
    
    // MARK: Handler
    
    
    @objc func handleCancle() {
        dismiss(animated: true, completion: nil)
    }
    
    func configNavigationBar() {
        navigationItem.title = "New Messager"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancle))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    func fetchUser() {
        USER_REF.observe(.childAdded) { snapshot in
            let uid = snapshot.key
            
            if uid != Auth.auth().currentUser?.uid {
                Database.fetchUser(with: uid, completion: { [weak self] user in
                    guard let self = self else { return }
                    self.users.append(user)
                    self.tableView.reloadData()
                })
            }
        }
    }
}
