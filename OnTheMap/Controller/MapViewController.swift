//
//  MapTabsViewController.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 7/3/21.
//

import UIKit
import MapKit

class MapViewController: NavigationViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUserData { zoomMapToStudentLocation() }
        fetchStudentLocations { zoomMapToStudentLocation() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.mapView.addAnnotations(studentLocations: studentLocations)
        zoomMapToStudentLocation()
    }
    
    func fetchStudentLocations(completion: () -> Void) {
        UdacityClient.getStudentLocations { (locations, error) in
            guard error == nil else {
                self.alert(message: "Something went wrong, please try again", title: "Get student locations error")
                return
            }
            
            (UIApplication.shared.delegate as! AppDelegate).studentLocations = locations
            
            self.mapView.addAnnotations(studentLocations: locations)
            self.zoomMapToStudentLocation()
        }
    }
    
    func fetchUserData(completion: () -> Void) {
        UdacityClient.getUserData { (studentInformation, error) in
            guard error == nil else {
                self.alert(message: "Something went wrong, please try again", title: "Get user data error")
                return
            }
            
            (UIApplication.shared.delegate as! AppDelegate).studentInformation = studentInformation
        }
    }
    
    func zoomMapToStudentLocation() {
        guard let studentInformation = studentInformation else { return }
        
        if let currentStudentLocation = studentLocations.first(where: {
            $0.firstName == studentInformation.firstName && $0.lastName == studentInformation.lastName
        }) {
            self.mapView.setCenter(latitude: currentStudentLocation.latitude, longitude: currentStudentLocation.longitude)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
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
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                if let url = URL(string: toOpen) {
                    app.open(url)
                }
                
            }
        }
    }
    
    override func onAddLocationFinish (location: StudentLocation?) {
        guard let location = location else {
            return
        }
        
        if let currentLocation = currentLocation {
            if let currentAnnotation = mapView.annotations.first(where: {
                $0.coordinate.latitude == currentLocation.latitude &&
                    $0.coordinate.longitude == currentLocation.longitude &&
                    $0.title == "\(currentLocation.firstName) \(currentLocation.lastName)" &&
                    $0.subtitle == currentLocation.mediaURL
            }) {
                mapView.removeAnnotation(currentAnnotation)
            }
        }
        
        mapView.addAnnotation(
            latitude: location.latitude,
            longitude: location.longitude,
            firstName: location.firstName,
            lastName: location.lastName,
            mediaURL: location.mediaURL
        )
        
        currentLocation = location
        zoomMapToStudentLocation()
    }
    
    override func refreshData() {
        handleRefreshData {
            self.mapView.addAnnotations(studentLocations: self.studentLocations)
            self.zoomMapToStudentLocation()
        }
    }
}
