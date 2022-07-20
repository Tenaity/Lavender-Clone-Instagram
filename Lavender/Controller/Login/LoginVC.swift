//
//  LoginVC.swift
//  Lavender
//
//  Created by Van Muoi on 5/11/22.
//

import UIKit
import Firebase
import AuthenticationServices
import CryptoKit
import GoogleSignIn

class LoginVC: UIViewController {
    
    // MARK: Properties
    let noInternetConnectionView: SnackbarView = NoInternetConnectionView()
    
    private var currentNonce: String?
    
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
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.placeholder = "Email"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        tf.layer.cornerRadius = 32 / 2
        return tf
    }()
    
    lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.frame.size.height = 30
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.placeholder = "Password"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        tf.isSecureTextEntry = true
        tf.layer.cornerRadius = 32 / 2
        return tf
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.rgbNormal()
        button.layer.cornerRadius = 32 / 2
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    lazy var loginButtonByApple: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign in with Apple", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.rgbPrimary()
        button.layer.cornerRadius = 32 / 2
        button.addTarget(self, action: #selector(handleLoginByApple), for: .touchUpInside)
        return button
    }()
    
    lazy var loginButtonByFacebook: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign in with Apple", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.rgbPrimary()
        button.layer.cornerRadius = 32 / 2
        button.addTarget(self, action: #selector(handleLoginByFacebook), for: .touchUpInside)
        return button
    }()
    
    
    let loginButtonByGoogle: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign in with Google", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.rgbPrimary()
        button.layer.cornerRadius = 32 / 2
        button.addTarget(self, action: #selector(handleLoginByGoogle), for: .touchUpInside)
        
        return button
    }()
    
    lazy var dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?   ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.rgbPrimary()]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    // MARK: Handlers
    
    @objc func handleShowSignUp() {
        let signUpVC = SignUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc func handleLoginByGoogle() {
        
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    @objc func handleLoginByFacebook() {
        
    }
    
    @objc func handleLoginByApple() {
        
        currentNonce = randomNonceString()
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(currentNonce!)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc func handleLogin() {
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text
        else { return }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: {
            (user, error) in
            
            // handle error
            if let error = error {
                print("Failed to login with error: ", error.localizedDescription)
                self.checkInternet()
                return
            }
            
            guard let mainTabVC = UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .compactMap({$0 as? UIWindowScene})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first?.rootViewController as? MainTabVC else { return }
            mainTabVC.configViewControllers()
            self.dismiss(animated: true, completion: nil)
        } )
    }
    
    @objc func formValidation() {
        guard
            emailTextField.hasText,
            passwordTextField.hasText
        else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.rgbNormal()
            return
        }
        
        loginButton.isEnabled = true
        loginButton.backgroundColor = UIColor.rgbPrimary()
    }

    // MARK: Init configure
    
    func setupSignInGoogle() {
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
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

//        checkInternet()
        
        super.viewDidLoad()
        
        ReachabilityHandler.shared.startListening()
        ReachabilityHandler.shared.onNetworkStateChanged = { [weak self] isReachable in
            self?.handleNetworkState(isReachable: isReachable)
        }
        
        setupSignInGoogle()
        
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        view.addSubview(emailTextField)
        view.addSubview(logoContainner)
        
        logoContainner.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 70, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        configViewComponents()
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    
    func configViewComponents() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField,  passwordTextField, loginButton, loginButtonByApple, loginButtonByGoogle])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.anchor(top: logoContainner.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError(
              "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

extension LoginVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let nonce = currentNonce,
           let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let appleIDToken = appleIDCredential.identityToken,
           let appleIDTokenString = String(data: appleIDToken, encoding: .utf8) {
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: appleIDTokenString, rawNonce: nonce)
            print("----> zo")
            Auth.auth().signIn(with: credential, completion: { result, error in
                
                print("----> ok")
            })
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    func navigateToMain() {
        guard let mainTabVC = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first?.rootViewController as? MainTabVC else { return }
        mainTabVC.configViewControllers()
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension LoginVC: GIDSignInDelegate {
    
    // MARK: config sign in with google
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("----> Error because \(error.localizedDescription)")
            return
        }
        
        guard let auth = user.authentication else { return }
        
        let credentails = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        
        Auth.auth().signIn(with: credentails, completion: { [weak self] (authResult, error) in
        
            guard let self = self else { return }
            
            if let error = error {
                print("----> Error because \(error.localizedDescription)")
                return
            }
            
            if let fullName = authResult?.user.displayName,
               let userName = authResult?.user.email,
               let profileImageUrl = authResult?.user.photoURL,
               let userId = authResult?.user.uid {
                let username = userName.replacingOccurrences(of: "@gmail.com", with: "")
            
                print("----> \(username)")
                
                let dictionaryValues = ["name": fullName,
                                        "username": username,
                                        "profileImageUrl": profileImageUrl.absoluteString]
                
                print("----> dictionaryValues \(dictionaryValues)")
                let values = [userId :dictionaryValues]
                

                Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, reference) in
                    
                    guard let mainTabVC = UIApplication.shared.connectedScenes
                            .filter({$0.activationState == .foregroundActive})
                            .compactMap({$0 as? UIWindowScene})
                            .first?.windows
                            .filter({$0.isKeyWindow}).first?.rootViewController as? MainTabVC else { return }
                    mainTabVC.configViewControllers()
                    self.dismiss(animated: true, completion: nil)
                        
                    })
            } else {
                self.navigateToMain()
            }

        })
    }
}

private extension LoginVC {
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
