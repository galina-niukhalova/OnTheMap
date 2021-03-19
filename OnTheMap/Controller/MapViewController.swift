//
//  MapTabsViewController.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 7/3/21.
//

import UIKit
import MapKit

class MapViewController: NavigationViewController, MKMapViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UdacityClient.getStudentLocations { (locations, error) in
            (UIApplication.shared.delegate as! AppDelegate).studentLocations = locations
            
            self.mapView.addAnnotations(studentLocations: locations)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.mapView.addAnnotations(studentLocations: studentLocations)
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
        print("onAddLocationFinish from map")
        mapView.addAnnotation(
            latitude: location.latitude,
            longitude: location.longitude,
            firstName: location.firstName,
            lastName: location.lastName,
            mediaURL: location.mediaURL
        )
    }
}
