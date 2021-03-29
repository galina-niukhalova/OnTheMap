//
//  MKMapView.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 19/3/21.
//

import Foundation
import MapKit

extension MKMapView {
    func createAnnotation(latitude: Double, longitude: Double, firstName: String?, lastName: String?, mediaURL: String?) -> MKPointAnnotation {
        let lat = CLLocationDegrees(latitude)
        let long = CLLocationDegrees(longitude)
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        
        if firstName != nil && lastName != nil {
            annotation.title = "\(firstName!) \(lastName!)"
        }
        
        if let mediaURL = mediaURL {
            annotation.subtitle = mediaURL
        }
        
        return annotation
    }
    
    func setCenter(latitude: Double, longitude: Double) {
        let lat = CLLocationDegrees(latitude)
        let long = CLLocationDegrees(longitude)
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.setCenter(coordinate, animated: false)
    }
    
    func zoomIntoRegion(latitude: Double, longitude: Double) {
        let latDelta:CLLocationDegrees = 0.05
        let lonDelta:CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        
        self.setRegion(region, animated: false)
    }
    
    func addAnnotations(studentLocations: [StudentLocation]) {
        var annotations = [MKPointAnnotation]()
        
        for location in studentLocations {
            annotations.append(
                createAnnotation(
                    latitude: location.latitude,
                    longitude: location.longitude,
                    firstName: location.firstName,
                    lastName: location.lastName,
                    mediaURL: location.mediaURL
                )
            )
        }
        
        self.removeAnnotations(self.annotations)
        self.addAnnotations(annotations)
    }
    
    func addAnnotation(latitude: Double, longitude: Double, firstName: String? = nil, lastName: String? = nil, mediaURL: String? = nil) {
        self.addAnnotation(createAnnotation(latitude: latitude, longitude: longitude, firstName: firstName, lastName: lastName, mediaURL: mediaURL))
    }
}
