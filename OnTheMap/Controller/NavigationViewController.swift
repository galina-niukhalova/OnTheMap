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
    var studentLocations: [StudentLocation] {
        return (UIApplication.shared.delegate as! AppDelegate).studentLocations
    }
    
    var studentInformation: StudentData? {
        return (UIApplication.shared.delegate as! AppDelegate).studentInformation
    }
    
    var currentLocation: StudentLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "On the Map"
        setNavigationItems()
    }
    
    func setNavigationItems(loading: Bool = false) {
        // Left items: Logout btn
        let logoutBtn = UIBarButtonItem.init(title: "LOGOUT", style: .plain, target: self, action: #selector(handleLogout));
        logoutBtn.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)
        ], for: .normal);
        navigationItem.leftBarButtonItem = logoutBtn
        
        // Right items: refresh data and add location
        let addLocationBtn = UIBarButtonItem(image: UIImage(named: "icon_addpin"), style: .plain, target: self, action: #selector(addLocation))
        let refreshButton: UIBarButtonItem
        
        if loading {
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            refreshButton = UIBarButtonItem(customView: activityIndicator)
            activityIndicator.startAnimating()
        } else {
            refreshButton = UIBarButtonItem(image: UIImage(named: "icon_refresh"), style: .plain, target: self, action: #selector(refreshData))
        }
        
        navigationItem.rightBarButtonItems = [addLocationBtn, refreshButton]
    }
    
    // Fetch new data and save result into delegate
    @objc func refreshData() {
        handleRefreshData {}
    }
    
    func handleRefreshData(completion: @escaping () -> Void) {
        setNavigationItems(loading: true)
        
        UdacityClient.getStudentLocations { (locations, error) in
            self.setNavigationItems(loading: false)
            
            if error != nil {
                return
            }
            
            (UIApplication.shared.delegate as! AppDelegate).studentLocations = locations
            completion()
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
        // check if user data exists
        guard let _ = studentInformation else {
            self.alert(message: .updateUserInfo, title: .missingUserData)
            return
        }
        
        // check if the student already posted a location
        if let currentLocation = studentLocations.first(where: {
            $0.firstName == self.studentInformation!.firstName && $0.lastName == self.studentInformation!.lastName
        }) {
            self.confirmationAlert(
                message: .overwriteCurrentLocation,
                title: .confirmNewLocation,
                confirmButtonTitle: "Overwrite",
                onConfirm: { self.handleLocationOverwrite(currentLocation) }
            )
        } else {
            performSegue(withIdentifier: "AddLocationSegue", sender: self)
        }
    }
    
    // Func to be override to update table view and map
    func onAddLocationFinish(location: StudentLocation?) {}
    
    // Passing a callback function into AddLocation modal
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddLocationSegue" {
            let controller = segue.destination as! UINavigationController
            let addLocationViewController = controller.topViewController as! AddLocationViewController
            addLocationViewController.onAddLocationFinish = onAddLocationFinish
            addLocationViewController.currentLocation = currentLocation
        }
    }
    
    func handleLocationOverwrite(_ currentLocation: StudentLocation) {
        self.currentLocation = currentLocation
        performSegue(withIdentifier: "AddLocationSegue", sender: self)
    }
}
