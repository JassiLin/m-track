//
//  MapViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 11/6/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapSegment: UISegmentedControl!
    
    var location: String = ""
    var geocoder = CLGeocoder()
    let annotation = MKPointAnnotation()
    var lat: CLLocationDegrees?
    var lon: CLLocationDegrees?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set initial location
        geocoder.geocodeAddressString(location){ placemarks, error in
            let placemark = placemarks?.first
            self.lat = placemark?.location?.coordinate.latitude
            self.lon = placemark?.location?.coordinate.longitude
            
            let initialLocation = CLLocation(latitude: self.lat!, longitude: self.lon!)
            self.mapView.centerToLocation(initialLocation)
            self.annotation.coordinate = CLLocationCoordinate2D(latitude: self.lat!, longitude: self.lon!)
            self.annotation.title = self.location
            self.mapView.addAnnotation(self.annotation)
        }
        

        
        
    }
    
    @IBAction func mapSegmentTapped(_ sender: Any) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

private extension MKMapView {
  func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}
