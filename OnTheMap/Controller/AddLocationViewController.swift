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
    var onAddLocationFinish: ((_: StudentLocation?) -> Void)?
    
    var updateLocationsView: (() -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func handleFindLocation(_ sender: Any) {
        guard let locationText = locationTextField.text else {
            // TODO alert, location can't be empty
            return
        }
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(locationText) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    
                    DispatchQueue.main.async {
                        let addLocationMapViewController = self.storyboard!.instantiateViewController(withIdentifier: "AddLocationMapViewController") as! AddLocationMapViewController
                        
                        addLocationMapViewController.latitude = location.coordinate.latitude
                        addLocationMapViewController.longitude = location.coordinate.longitude
                        addLocationMapViewController.url = self.URLTextField.text ?? ""
                        addLocationMapViewController.locationString = locationText
                        addLocationMapViewController.onAddLocationFinish = self.onAddLocationFinish
                        
                        self.navigationController!.pushViewController(addLocationMapViewController, animated: true)
                    }
                    return
                }
            }
            
            // TODO: alert can't find location
        }
    }
    
    @IBAction func handleCancel(_ sender: Any) {
        self.dismiss(animated: true) {
            if let onAddLocationFinish = self.onAddLocationFinish {
                onAddLocationFinish(nil)
            }
        }
    }
}
