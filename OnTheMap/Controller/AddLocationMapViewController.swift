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
    @IBOutlet var finishButton: LoadingButton!
    
    var currentLocation: StudentLocation? = nil
    
    var studentLocations: [StudentLocation] {
        return StudentInformation.sharedInstance.locations
    }
    
    var studentPersonalInformation: StudentData {
        return StudentInformation.sharedInstance.studentPersonalInformation!
    }
    
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
        finishButton.showLoading()
        
        if let currentLocation = currentLocation {
            UdacityClient.putStudentLocation(objectId: currentLocation.objectId, uniqueKey: studentPersonalInformation.key, firstName: studentPersonalInformation.firstName, lastName: studentPersonalInformation.lastName, latitude: self.latitude, longitude: self.longitude, mapString: self.locationString, mediaURL: self.url, completion: handlePutStudentLocationResponse)
        } else {
            UdacityClient.postStudentLocation(uniqueKey: studentPersonalInformation.key, firstName: studentPersonalInformation.firstName, lastName: studentPersonalInformation.lastName, latitude: self.latitude, longitude: self.longitude, mapString: self.locationString, mediaURL: self.url, completion: handlePostStudentLocationResponse)
        }
    }
    
    func handlePostStudentLocationResponse(objectId: String?, error: Error?) {
        guard error == nil && objectId != nil else {
            self.alert(message: .general, title: .addLocation)
            return
        }
        
        handleAddStudentLocation(objectId!)
    }
    
    func handlePutStudentLocationResponse(success: Bool, error: Error?) {
        guard success else {
            self.alert(message: .general, title: .addLocation)
            return
        }
        
        handleAddStudentLocation(currentLocation!.objectId)
    }
    
    func handleAddStudentLocation(_ objectId: String) {
        let studentLocation = StudentLocation(uniqueKey: studentPersonalInformation.key, firstName: studentPersonalInformation.firstName, lastName: studentPersonalInformation.lastName, latitude: self.latitude, longitude: self.longitude, mapString: self.locationString, mediaURL: self.url, objectId: objectId)
        
        if let currentLocation = currentLocation {
            // overwrite location
            if let currentStudentLocationIndex = studentLocations.firstIndex(where: {
                $0.firstName == currentLocation.firstName &&
                    $0.lastName == currentLocation.lastName &&
                    $0.longitude == currentLocation.longitude &&
                    $0.latitude == currentLocation.latitude
            }) {
                StudentInformation.sharedInstance.locations[currentStudentLocationIndex] = studentLocation
            }
        } else {
            // new location
            StudentInformation.sharedInstance.locations.insert(studentLocation, at: 0)
        }
        
        self.dismiss(animated: true) {
            self.onAddLocationFinish?(studentLocation)
        }
        
        self.finishButton.hideLoading()
    }
}
