//
//  SceneDelegate.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 6/3/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        // Set the login screen as a default root controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "AuthViewController")
        window?.rootViewController = loginNavController
    }
    
    func changeRootViewController(identifier: String, animated: Bool = true) {
        guard let window = self.window else {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: identifier)
        
        // change the root view controller to a specific view controller
        window.rootViewController = vc
        
        // add animation
        UIView.transition(with: window,
                          duration: 0.3,
                          options: [.transitionCrossDissolve],
                          animations: nil,
                          completion: nil)
    }
}

