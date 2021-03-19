//
//  AddLocationMapViewController.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 9/3/21.
//

import UIKit
import MapKit

class AddLocationMapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    
    var latitude: Double = 0
    var longitude: Double = 0
    var locationString: String = ""
    var url: String = ""
    var onAddLocationFinish: ((_: StudentLocation) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.addAnnotation(
            latitude: latitude,
            longitude: longitude,
            mediaURL: url
        )
        mapView.setCenter(latitude: latitude,longitude: longitude)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    @IBAction func handleFinish(_ sender: Any) {
        UdacityClient.getUserData { (response, _) in
            guard let response = response else {
                return
            }
            let studentLocation = StudentLocation(uniqueKey: response.key, firstName: response.first_name, lastName: response.last_name, latitude: self.latitude, longitude: self.longitude, mapString: self.locationString, mediaURL: self.url)
            
            
            UdacityClient.postStudentLocation(studentLocation: studentLocation) { (success, error) in
                (UIApplication.shared.delegate as! AppDelegate).studentLocations.append(studentLocation)
                
                if success {
                    self.dismiss(animated: true) {
                        if let onAddLocationFinish = self.onAddLocationFinish {
                            onAddLocationFinish(studentLocation)
                        }
                    }
                    
                } else {
                    if let error = error {
                        print("postStudentLocation: \(error)")
                    }
                }
            }
        }
    }
}
