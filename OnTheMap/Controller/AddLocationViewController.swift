//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 7/3/21.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var URLTextField: UITextField!
    @IBOutlet var findLocationButton: LoadingButton!
    
    var onAddLocationFinish: ((_: StudentLocation?) -> Void)?
    var currentLocation: StudentLocation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkCtaButtonStatus()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        findLocationButton.hideLoading()
    }
    
    @IBAction func handleFindLocation(_ sender: Any) {
        findLocationButton.showLoading()
        let locationText = locationTextField.text!
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(locationText) { (placemarks, error) in
            guard error == nil else {
                self.findLocationButton.hideLoading()
                self.alert(message: "Something went wrong, please provide another location and try again", title: "Location error")
                return
            }
            
            if let placemark = placemarks?[0] {
                let location = placemark.location!
                
                DispatchQueue.main.async {
                    let addLocationMapViewController = self.storyboard!.instantiateViewController(withIdentifier: "AddLocationMapViewController") as! AddLocationMapViewController
                    
                    addLocationMapViewController.latitude = location.coordinate.latitude
                    addLocationMapViewController.longitude = location.coordinate.longitude
                    addLocationMapViewController.url = self.URLTextField.text ?? ""
                    addLocationMapViewController.locationString = locationText
                    addLocationMapViewController.onAddLocationFinish = self.onAddLocationFinish
                    addLocationMapViewController.currentLocation = self.currentLocation
                    
                    self.navigationController!.pushViewController(addLocationMapViewController, animated: true)
                }
                return
            }
        }
    }
    
    @IBAction func handleCancel(_ sender: Any) {
        self.dismiss(animated: true) {
            self.onAddLocationFinish?(nil)
        }
    }
    
    @IBAction func handleLocationChange(_ sender: Any) {
        checkCtaButtonStatus()
    }
    
    @IBAction func handleURLChange(_ sender: Any) {
        checkCtaButtonStatus()
    }
    
    func checkCtaButtonStatus() {
        let isEnabled = locationTextField.text != "" && URLTextField.text != ""
        
        if isEnabled {
            findLocationButton.isEnabled = true
            findLocationButton.alpha = 1
        } else {
            findLocationButton.isEnabled = false
            findLocationButton.alpha = 0.5
        }
    }
}
