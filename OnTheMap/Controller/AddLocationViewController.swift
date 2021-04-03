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
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        URLTextField.delegate = self
        locationTextField.delegate = self
        
        setCtaButtonStatus()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        findLocationButton.hideLoading()
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
    
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // move cursor from location text field to URL
        if textField == locationTextField {
            URLTextField.becomeFirstResponder()
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
        
        if locationTextField.isFirstResponder ||
            URLTextField.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification) / 2
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if locationTextField.isFirstResponder ||
            URLTextField.isFirstResponder {
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
