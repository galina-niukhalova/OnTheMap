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
        
        fetchUserData()
        fetchStudentLocations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.addAnnotations(studentLocations: studentLocations)
        zoomMapToStudentLocation()
    }
    
    func fetchStudentLocations() {
        UdacityClient.getStudentLocations { (locations, error) in
            guard error == nil else {
                self.alert(message: .general, title: .getStudentLocation)
                return
            }
            
            StudentInformation.sharedInstance.locations = locations
            self.mapView.addAnnotations(studentLocations: locations)
            self.zoomMapToStudentLocation()
            
        }
    }
    
    func fetchUserData() {
        UdacityClient.getUserData { (studentInformation, error) in
            guard error == nil else {
                self.alert(message: .general, title: .getUserData)
                return
            }
            
            StudentInformation.sharedInstance.studentPersonalInformation = studentInformation
            self.zoomMapToStudentLocation()
        }
    }
    
    func zoomMapToStudentLocation() {
        guard let studentPersonalInformation = studentPersonalInformation else { return }
        
        // zoom map if user already posted they location
        if let currentStudentLocation = studentLocations.first(where: {
            $0.firstName == studentPersonalInformation.firstName && $0.lastName == studentPersonalInformation.lastName
        }) {
            self.mapView.setCenter(latitude: currentStudentLocation.latitude, longitude: currentStudentLocation.longitude)
        }
    }
    
    // Callback function fires on adding a new location
    override func onAddLocationFinish (location: StudentLocation?) {
        guard let location = location else {
            return
        }
        
        // remove existing pin in case of location override
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
        
        // add new pin
        mapView.addAnnotation(
            latitude: location.latitude,
            longitude: location.longitude,
            firstName: location.firstName,
            lastName: location.lastName,
            mediaURL: location.mediaURL
        )
        
        // save user location
        currentLocation = location
        
        // zoom map to a new location
        zoomMapToStudentLocation()
    }
    
    // Callback funnction fires on clicking refresh icon
    override func refreshData() {
        handleRefreshData {
            self.mapView.addAnnotations(studentLocations: self.studentLocations)
            self.zoomMapToStudentLocation()
        }
    }
    
    
    // MARK: - MKMapViewDelegate
        
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Set pin view
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
    
    
    // open location URL on pin description click
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
}
