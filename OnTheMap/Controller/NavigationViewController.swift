//
//  NavigationViewController.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 7/3/21.
//

import UIKit
import MapKit
import FBSDKLoginKit

class NavigationViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    
    var studentLocations: [StudentLocation] {
        return (UIApplication.shared.delegate as! AppDelegate).studentLocations
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "On the Map"
        setNavigationItems()
    }
    
    func setNavigationItems() {
        // Left items: Logout btn
        let logoutBtn = UIBarButtonItem.init(title: "LOGOUT", style: .plain, target: self, action: #selector(handleLogout));
        logoutBtn.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)
        ], for: .normal);
        navigationItem.leftBarButtonItem = logoutBtn
        
        // Right items: refresh data and add location
        let addLocationBtn = UIBarButtonItem(image: UIImage(named: "icon_addpin"), style: .plain, target: self, action: #selector(addLocation))
        let refreshButton = UIBarButtonItem(image: UIImage(named: "icon_refresh"), style: .plain, target: self, action: #selector(refreshData))
        navigationItem.rightBarButtonItems = [addLocationBtn, refreshButton]
    }
    
    // Fetch a new data and save result into delegate
    @objc func refreshData() {
        UdacityClient.getStudentLocations { (locations, error) in
            if error != nil {
                return
            }
            
            (UIApplication.shared.delegate as! AppDelegate).studentLocations = locations
        }
    }
    
    // Delete user session and change view controller to Auth
    @objc func handleLogout() {
        // User is logged in via FB
        if let _ = AccessToken.current {
            let loginManager = LoginManager()
            loginManager.logOut()
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(identifier: "AuthViewController")
        } else {
            // User is logged in via Udacity credentials
            UdacityClient.deleteSession { _ in
                // Change root controller to AuthViewController
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(identifier: "AuthViewController")
            }
        }
    }
    
    // Show AddLocation view controller
    @objc func addLocation() {
        performSegue(withIdentifier: "AddLocationSegue", sender: self)
    }
    
    // Func to be override to update table view and map
    func onAddLocationFinish(location: StudentLocation?) {}
    
    // Passing a callback function into AddLocation modal
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddLocationSegue" {
            let controller = segue.destination as! UINavigationController
            let addLocationViewController = controller.topViewController as! AddLocationViewController
            addLocationViewController.onAddLocationFinish = onAddLocationFinish
        }
    }
    
}
