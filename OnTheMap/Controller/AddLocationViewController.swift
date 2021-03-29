//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 7/3/21.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var URLTextField: UITextField!
    @IBOutlet var findLocationButton: LoadingButton!
    
    var onAddLocationFinish: ((_: StudentLocation?) -> Void)?
    var currentLocation: StudentLocation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.URLTextField.delegate = self
        
        setCtaButtonStatus()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        findLocationButton.hideLoading()
    }
    
    @IBAction func handleFindLocation(_ sender: Any) {
        findLocationButton.showLoading()
        let locationText = locationTextField.text!
        
        let geocoder = CLGeocoder()
        
        // Convert string to geolocation
        geocoder.geocodeAddressString(locationText) { (placemarks, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    self.findLocationButton.hideLoading()
                    self.alert(message: .findLocation, title: .findLocation)
                }
                return
            }
            
            if let placemark = placemarks?[0] {
                let location = placemark.location!
                
                // show AddLocationMapViewController if geolocation was found
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
        setCtaButtonStatus()
    }
    
    @IBAction func handleURLChange(_ sender: Any) {
        setCtaButtonStatus()
    }
    
    func setCtaButtonStatus() {
        let isEnabled = locationTextField.text != "" && URLTextField.text != ""
        findLocationButton.setButtonStatus(isEnabled: isEnabled)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
