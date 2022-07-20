//
//  SignUpVC.swift
//  Lavender
//
//  Created by Van Muoi on 5/13/22.
//

import UIKit
import Firebase

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    
    var imageSelected: Bool = false
    let noInternetConnectionView: SnackbarView = NoInternetConnectionView()
    
    let logoContainner: UIView = {
        let view = UIView()
        let logoImage = UIImageView(image: UIImage(named: "banner1"))
        logoImage.contentMode = .scaleAspectFill
        view.addSubview(logoImage)
        logoImage.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 100, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 250, height: 50)
        logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }()
    
//    let plusPhotoBtn: UIButton = {
//        let button = UIButton(type: .system)
//        button.setBackgroundImage(UIImage(named: "plus_purple2"), for: .normal)
//        button.addTarget(self, action: #selector(handleSelectProfilePhoto), for: .touchUpInside)
//        return button
//    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.placeholder = "Email"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.placeholder = "Password"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let fullNameTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.placeholder = "Full Name"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let userNameTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.placeholder = "Username"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.rgbNormal()
        button.layer.cornerRadius = 32 / 2
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?   ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.rgbPrimary()]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    // MARK: Handlers
    
    @objc func handleShowSignUp() {
        navigationController?.popViewController(animated: true)
    }
    
//    @objc func handleSignUp() {
//        // properties
//        guard
//            let email = emailTextField.text,
//            let password = passwordTextField.text,
//            let fullName = fullNameTextField.text,
//            let username = userNameTextField.text?.lowercased()
//        else { return }
//
//        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
//
//            // handle error
//            if let error = error {
//                print("Failed to create user with error: ", error.localizedDescription)
//                return
//            }
//
//            // set profile image
//            guard let profileImg = self.plusPhotoBtn.imageView?.image else { return }
//
//            // upload data
//            guard let updoadData = profileImg.jpegData(compressionQuality: 0.3) else { return }
//
//            // place image in firebase storage
//            let filename = NSUUID().uuidString
//            DispatchQueue.main.async {
//                let storageRef = Storage.storage().reference().child("profile_images").child(filename)
//                storageRef.putData(updoadData, metadata: nil) { (metadata, error) in
//                    guard let metadata = metadata else {
//                        print("an error occured")
//                        return
//                    }
//                    // Metadata contains file metadata such as size and content-type.
//                    let size = metadata.size
//                    print("Image size: \(size)")
//                    storageRef.downloadURL(completion: { (url, err) in
//                        guard let downloadURL = url else {
//                            print("an error ocured")
//                            return
//                        }
//                        print("Successfully uploaded profile image into Firebase storage with URL:", downloadURL)
//
//                        let downloadURLString = downloadURL.absoluteString
//                        let dictionaryValues = ["name": fullName,
//                                                "username": username,
//                                                "profileImageUrl": downloadURLString]
//                        let values = [user?.user.uid :dictionaryValues]
//
//                        Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, reference) in
//                        })
//                    })
//                }
//            }
//        }
//    }
    
    @objc func handleSignUp() {
        
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            let fullName = fullNameTextField.text,
            let username = userNameTextField.text?.lowercased()
        else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in

            // handle error
            if let error = error {
                print("Failed to create user with error: ", error.localizedDescription)
                return
            }

            let dictionaryValues = ["name": fullName,
                                    "username": username,
                                    "profileImageUrl": ""]
            
            let values = [user?.user.uid :dictionaryValues]

            Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, reference) in
                guard let mainTabVC = UIApplication.shared.connectedScenes
                        .filter({$0.activationState == .foregroundActive})
                        .compactMap({$0 as? UIWindowScene})
                        .first?.windows
                        .filter({$0.isKeyWindow}).first?.rootViewController as? MainTabVC else { return }
                mainTabVC.configViewControllers()
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    @objc func formValidation() {
        guard
            emailTextField.hasText,
            passwordTextField.hasText,
            fullNameTextField.hasText,
            userNameTextField.hasText
        else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgbNormal()
            return
        }
        
        signUpButton.isEnabled = true
        signUpButton.backgroundColor = UIColor.rgbPrimary()
    }
    
//    @objc func handleSelectProfilePhoto() {
//
//        // configure image picker
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.allowsEditing = true
//
//        // present image picker
//        imagePicker.modalPresentationStyle = .overFullScreen
//        self.present(imagePicker, animated: true, completion: nil)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        // selected image
//        guard let profileImage = info[.editedImage] as? UIImage else {
//            imageSelected = false
//            return
//        }
//
//        // set imageSelected to true
//        imageSelected = true
//
//        // configure plusPhotoBtn with selected image
//
//        // MARK: photo
//        plusPhotoBtn.layer.cornerRadius = plusPhotoBtn.frame.width / 2
//        plusPhotoBtn.layer.masksToBounds = true
//        plusPhotoBtn.layer.borderColor = UIColor.black.cgColor
//        plusPhotoBtn.layer.borderWidth = 2
//        plusPhotoBtn.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
//
//        self.dismiss(animated: true, completion: nil)
//    }
    
    // MARK: Init
    
    func checkInternet() {
        
        DispatchQueue.main.async {
            if InternetConnectionManager.isConnectedToNetwork(){
                print("Connected")
            }else{
                print("Not Connected")
                // Create new Alert
                var dialogMessage = UIAlertController(title: "Opps, no connection", message: "You should connect internet!", preferredStyle: .alert)
                
                // Create OK button with action handler
                let openWifi = UIAlertAction(title: "Open wifi", style: .default, handler: { (action) -> Void in
                    if let url = URL(string: "App-Prefs:root=WIFI") {
                        if UIApplication.shared.canOpenURL(url) {
                           let url =  UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                 })
                
                let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: { (action) -> Void in
                    print("Cancel button tapped")
                })
                
                //Add OK button to a dialog message
                dialogMessage.addAction(openWifi)
                
                dialogMessage.addAction(cancelButton)
                // Present Alert to
                self.present(dialogMessage, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ReachabilityHandler.shared.startListening()
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        ReachabilityHandler.shared.startListening()
        ReachabilityHandler.shared.onNetworkStateChanged = { [weak self] isReachable in
            self?.handleNetworkState(isReachable: isReachable)
        }
        
        view.backgroundColor = .white
        
//        view.addSubview(plusPhotoBtn)
//        plusPhotoBtn.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
//        plusPhotoBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        view.addSubview(logoContainner)
        logoContainner.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 100, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        
        configViewComponents()
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    
    func configViewComponents() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, fullNameTextField, userNameTextField, passwordTextField, signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        
        stackView.anchor(top: logoContainner.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
    }
}

private extension SignUpVC {
    func handleNetworkState(isReachable: Bool) {
        var content: NoInternetContent {
            return NoInternetContent(message: "Opps, no connection")
        }
        guard !isReachable else {
            noInternetConnectionView.hide()
            return
        }
        noInternetConnectionView.show(content: content)
        checkInternet()
    }
}
