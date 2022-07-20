//
//  EditProfileController.swift
//  Lavender
//
//  Created by Van Muoi on 7/3/22.
//

import Foundation
import UIKit
import Firebase

class EditProfileController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: Properties
    
    var user: User?
    var imageChanged = false
    var usernameChanged = false
    var userProfileController: UserProfileVC?
    var updatedUsername: String?
    
    // handle image
    var imagePicker = UIImagePickerController()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.black
        button.setTitle("Change image profile", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleChangeImageNew), for: .touchUpInside)
        return button
    }()
    
    let separator: UIView = {
       let uv = UIView()
        uv.backgroundColor = .lightGray
        return uv
    }()
    
    let usernameTextField: UITextField = {
       let tf = UITextField()
        tf.textAlignment = .left
        tf.borderStyle = .none
        return tf
    }()
    
    let fullnameTextField: UITextField = {
       let tf = UITextField()
        tf.textAlignment = .left
        tf.borderStyle = .none
        tf.isUserInteractionEnabled = false
        return tf
    }()
    
    let usernameLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Username"
        lb.font = UIFont.systemFont(ofSize: 16)
        return lb
    }()
    
    let fullnameLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Name"
        lb.font = UIFont.systemFont(ofSize: 16)
        return lb
    }()
    
    let usernameSeparatorView: UIView = {
       let uv = UIView()
        uv.backgroundColor = .lightGray
        return uv
    }()
    
    let fullnameSeparatorView: UIView = {
       let uv = UIView()
        uv.backgroundColor = .lightGray
        return uv
    }()
    
    // MARK: Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configNavigationBar()
        
        configViewComponents()
        
        usernameTextField.delegate = self
        
        loadUserData()
        
    }
    
    func configViewComponents() {
        
        view.backgroundColor = .white
        
        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 150)
        let containerView = UIView(frame: frame)
        view.addSubview(containerView)
        
        containerView.addSubview(profileImageView)
        profileImageView.anchor(top: containerView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        profileImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        containerView.addSubview(changePhotoButton)
        
        changePhotoButton.anchor(top: profileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        changePhotoButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        containerView.addSubview(separator)
        
        separator.anchor(top: nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        view.addSubview(fullnameLabel)
        fullnameLabel.anchor(top: containerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20,
        paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        view.addSubview(usernameLabel)
        usernameLabel.anchor(top: fullnameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20,
        paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        view.addSubview(fullnameTextField)
        fullnameTextField.anchor(top: containerView.bottomAnchor, left: fullnameLabel.rightAnchor, bottom: nil, right:
        view.rightAnchor, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: (view.frame.width / 1.6), height: 0)
        view.addSubview(usernameTextField)
        usernameTextField.anchor(top: fullnameTextField.bottomAnchor, left: usernameLabel.rightAnchor, bottom: nil, right:
        view.rightAnchor, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: (view.frame.width / 1.6), height: 0)
        view.addSubview(fullnameSeparatorView)
        fullnameSeparatorView.anchor(top: nil, left: fullnameTextField.leftAnchor, bottom: fullnameTextField.bottomAnchor, right:
        view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 12, width: 0, height: 0.5)
        view.addSubview(usernameSeparatorView)
        usernameSeparatorView.anchor (top: nil, left: usernameTextField.leftAnchor, bottom: usernameTextField.bottomAnchor, right:
        view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 12, width: 0, height: 0.5)
        
    }
    
    func configNavigationBar() {
        
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleUpdateProfile))
    }
    
    func loadUserData() {
        guard let user = user else { return }
        
        if let profileImageUrl = user.profileImage, profileImageUrl != "" {
            self.profileImageView.loadImage(with: profileImageUrl)
        } else {
            self.profileImageView.image = UIImage(named: "user_default")
        }
        
        usernameTextField.text = user.username
        fullnameTextField.text = user.name
    }
    
    // MARK: Handler
    
    @objc func handleChangeImageNew() {
        let picker = PickerController()
        picker.applyFilter = true // to apply filter after selecting the picture by default false
        picker.selectImage(self){ image in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.profileImageView.image = image
                self.imageChanged = true
            }
        }
    }
    
    @objc func handleChangeImage(_ sender: UIButton) {
        
        imagePicker.delegate = self
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.openCamera()
            }))
            
            alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
                self.openGallary()
            }))
            
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                alert.popoverPresentationController?.sourceView = sender
                alert.popoverPresentationController?.sourceRect = sender.bounds
                alert.popoverPresentationController?.permittedArrowDirections = .up
            default:
                break
            }
            
            self.present(alert, animated: true, completion: nil)
    }
    
    @objc func handleUpdateProfile() {
        
        view.endEditing(true)
        
        if usernameChanged {
            updateUsername()
        }
        
        if imageChanged {
            updateProfileImage()
        }
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: API
    
    func updateUsername() {
        guard let currentUid = Auth.auth().currentUser?.uid,
            let updatedUsername = self.updatedUsername,
            usernameChanged == true else { return }
        
        USER_REF.child(currentUid).child("username").setValue(updatedUsername) { [weak self] _,_ in
            guard let self = self,
                  let userProfileController = self.userProfileController else { return }
            
            userProfileController.fetchCurrentUserData()
            self.usernameChanged = false
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateProfileImage() {
        guard imageChanged == true,
        let currentUid = Auth.auth().currentUser?.uid,
        let user = self.user else { return }
        
        if user.profileImage != "" {
            Storage.storage().reference(forURL: user.profileImage).delete(completion: nil)
        }
        
        
        // upload data
        guard let updoadData = profileImageView.image?.jpegData(compressionQuality: 0.3) else { return }
        
        // place image in firebase storage
        let filename = NSUUID().uuidString
        
        DispatchQueue.main.async {
            let storageRef = Storage.storage().reference().child("profile_images").child(filename)
            storageRef.putData(updoadData, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    print("an error occured")
                    return
                }
                // Metadata contains file metadata such as size and content-type.
                let size = metadata.size
                print("Image size: \(size)")
                storageRef.downloadURL(completion: { (url, err) in
                    guard let downloadURL = url else {
                        print("an error ocured")
                        return
                    }
                    print("Successfully uploaded profile image into Firebase storage with URL:", downloadURL)
                    
                    let downloadURLString = downloadURL.absoluteString
                    
                    USER_REF.child(currentUid).child("profileImageUrl").setValue(downloadURLString) { [weak self] _,_ in
                        
                        guard let self = self,
                              let userProfileController = self.userProfileController else { return }
                        
                        userProfileController.fetchCurrentUserData()
                        self.imageChanged = false
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                })
            }
        }
        
    
    }
    
    // MARK: Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // selected image
        
        if let selectedImage = info[.editedImage] as? UIImage {
            profileImageView.image = selectedImage
            imageChanged = true
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func openGallary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textView: UITextField) {
        guard let user = self.user else { return }
        
        let trimmedString = usernameTextField.text?.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        
        guard user.username != trimmedString, user.username != "" else {
            usernameChanged = false
            return
        }
        updatedUsername = trimmedString?.lowercased()
        usernameChanged = true
    }
    
}
