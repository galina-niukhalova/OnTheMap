//
//  NavigationViewController.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 7/3/21.
//

import UIKit

class NavigationViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
            
        navigationItem.title = "On the Map"
        
        let logoutBtn = UIBarButtonItem.init(title: "LOGOUT", style: .plain, target: self, action: #selector(handleLogout));
        logoutBtn.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)
        ], for: .normal);
        navigationItem.leftBarButtonItem = logoutBtn
        
        let addLocationBtn = UIBarButtonItem(image: UIImage(named: "icon_addpin"), style: .plain, target: self, action: #selector(addLocation))
        let refreshButton = UIBarButtonItem(image: UIImage(named: "icon_refresh"), style: .plain, target: self, action: #selector(refreshData))
        navigationItem.rightBarButtonItems = [addLocationBtn, refreshButton]
    }
    
    @objc func addLocation() {
        let addLocationViewController = self.storyboard!.instantiateViewController(withIdentifier: "AddLocationViewController") as! AddLocationViewController
        
        navigationController!.pushViewController(addLocationViewController, animated: true)
    }
    
    @objc func refreshData() {
        
    }
    
    @objc func handleLogout() {
        UdacityClient.Auth.sessionId = ""
        
        // Change root controller to AuthViewController
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(identifier: "AuthViewController")
    }
}
