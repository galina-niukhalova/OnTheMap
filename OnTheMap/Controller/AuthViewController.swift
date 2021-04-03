//
//  AuthViewController.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 6/3/21.
//

import UIKit
import FBSDKLoginKit

class AuthViewController: UIViewController, LoginButtonDelegate, UITextFieldDelegate {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: LoadingButton!
    @IBOutlet var signupView: UIStackView!
    
    var fbLoginButton = FBLoginButton()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        setLoginButtonState()
        renderFBLoginButton()
        checkFBLogin()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setFBLoginButtonPosition()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Actions
    
    @IBAction func handleLogin(_ sender: Any) {
        // show loading
        loginButton.showLoading()
        
        // create session
        UdacityClient.createSession(username: emailTextField.text ?? "", password: passwordTextField.text ?? "", complition: handleCreateSessionResponse)
    }
    
    // Open Udacity website in Safari
    @IBAction func handleSignup(_ sender: Any) {
        let app = UIApplication.shared
        if let url = URL(string: UdacityClient.signupURL) {
            app.open(url)
        }
    }
    
    
    // Fires on typing in email field
    @IBAction func handleEmailChange(_ sender: Any) {
        setLoginButtonState()
    }
    
    // Fires on typing in password field
    @IBAction func handlePasswordChange(_ sender: Any) {
        setLoginButtonState()
    }
    
    // Enable or Disable login button
    func setLoginButtonState() {
        let isEnabled = emailTextField.text != "" && passwordTextField.text != ""
        loginButton.setButtonStatus(isEnabled: isEnabled)
    }
    
    func handleCreateSessionResponse(error: Error?) {
        // hide loading
        loginButton.hideLoading()
        
        // show an alert if there is an error
        if let error = error {
            self.alert(message: error.localizedDescription, title: .failedLogin)
            return
        }
        
        // change root controller to MapTabsViewController in case of success login
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(identifier: "MapTabsViewController")
    }
    
    // MARK: FB login
    
    func renderFBLoginButton() {
        fbLoginButton.delegate = self
        setFBLoginButtonPosition()
        
        view.addSubview(fbLoginButton)
    }
    
    func setFBLoginButtonPosition() {
        let spacing: CGFloat = view.frame.width < view.frame.height ? 40 : 10
        
        let positionY = view.frame.size.height - fbLoginButton.frame.height - spacing
        
        fbLoginButton.center = CGPoint(x: view.center.x, y: positionY)
    }
    
    // Show map view if an user already logged in via facebook
    func checkFBLogin() {
        if let token = AccessToken.current,
           !token.isExpired {
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(identifier: "MapTabsViewController")
        }
    }
    
    // Sent to the LoginButtonDelegate when the fb button was used to login
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        checkFBLogin()
    }
    
    // Sent to the LoginButtonDelegate when the fb button was used to logout
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {}
    
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Move cursor from email to password text field
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
            return false
        }
        
        // Hide a keyboard on click Enter
        textField.resignFirstResponder()
        return true
    }
    
    // Hide a keyboard on touch outside of text field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // MARK: Keyboard notifications
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard view.frame.origin.y == 0 else {
            return
        }
        
        if emailTextField.isFirstResponder ||
            passwordTextField.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification) / 2
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if emailTextField.isFirstResponder ||
            passwordTextField.isFirstResponder {
            view.frame.origin.y = 0
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}

