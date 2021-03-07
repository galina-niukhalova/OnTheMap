//
//  AuthViewController.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 6/3/21.
//

import UIKit

class AuthViewController: UIViewController {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: LoginButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func handleLogin(_ sender: Any) {
        UdacityClient.createSession(username: emailTextField.text ?? "", password: passwordTextField.text ?? "", complition: handleCreateSessionResponse)
    }
    
    func handleCreateSessionResponse(error: Error?) {
        // Change root controller to MapTabsViewController
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(identifier: "MapTabsViewController")
    }
    
    @IBAction func handleSignup(_ sender: Any) {
    }
}

