//
//  AuthViewController.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 6/3/21.
//

import UIKit
import FBSDKLoginKit

class AuthViewController: UIViewController, LoginButtonDelegate {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: LoadingButton!
    
    let udacitySignupUrl = "https://auth.udacity.com/sign-up"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func handleCreateSessionResponse(error: Error?) {
        // hide loading
        loginButton.hideLoading()
        
        // show an alert if there is an error
        if let error = error {
            self.alert(message: error.localizedDescription, title: "Login has failed")
            return
        }
        
        // change root controller to MapTabsViewController in case of success login
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(identifier: "MapTabsViewController")
    }
    
    @IBAction func handleSignup(_ sender: Any) {
        // Open Udacity website in Safari
        let app = UIApplication.shared
        if let url = URL(string: udacitySignupUrl) {
            app.open(url)
        }
    }
    
    @IBAction func handleEmailChange(_ sender: Any) {
        setLoginButtonState()
    }
    
    @IBAction func handlePasswordChange(_ sender: Any) {
        setLoginButtonState()
    }
    
    func setLoginButtonState() {
        let isEnabled = emailTextField.text != "" && passwordTextField.text != ""
        
        if isEnabled {
            loginButton.isEnabled = true
            loginButton.alpha = 1
        } else {
            loginButton.isEnabled = false
            loginButton.alpha = 0.5
        }
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        checkFBLogin()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {}
    
    func renderFBLoginButton() {
        let loginButton = FBLoginButton()
        let screenSize:CGRect = UIScreen.main.bounds
        let screenHeight = screenSize.height
        let newCenterY = screenHeight - loginButton.frame.height - 40
        let newCenter = CGPoint(x: view.center.x, y: newCenterY)
        loginButton.center = newCenter
        
        
        loginButton.delegate = self
        view.addSubview(loginButton)
    }
    
    func checkFBLogin() {
        if let token = AccessToken.current,
           !token.isExpired {
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(identifier: "MapTabsViewController")
        }
    }
}

