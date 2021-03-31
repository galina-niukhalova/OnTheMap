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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        setLoginButtonState()
        renderFBLoginButton()
        checkFBLogin()
    }
    
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
    
    // Enable or Disable login button
    func setLoginButtonState() {
        let isEnabled = emailTextField.text != "" && passwordTextField.text != ""
        loginButton.setButtonStatus(isEnabled: isEnabled)
    }
    
    func renderFBLoginButton() {
        // display fb button under Signup link
        let spacing: CGFloat = 40
        let fbLoginButton = FBLoginButton()
        let positionY = signupView.frame.origin.y + signupView.frame.height + spacing
        fbLoginButton.center = CGPoint(x: view.center.x, y: positionY)
        
        fbLoginButton.delegate = self
        
        view.addSubview(fbLoginButton)
    }
    
    // Show map view if an user already logged in via facebook
    func checkFBLogin() {
        if let token = AccessToken.current,
           !token.isExpired {
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(identifier: "MapTabsViewController")
        }
    }
    
    // MARK: - LoginButtonDelegate
    
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
}

