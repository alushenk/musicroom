//
//  LocationManager.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 2019-04-25.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager : NSObject {
    private let locationManager = CLLocationManager()

    // TODO: Consider adding observers to track current state
    var inValidState: Bool = false

    var location: CLLocation? {
        get {
            return locationManager.location
        }
    }

    static let sharedInstance : LocationManager = {
        let instance = LocationManager()
        instance.startLocationTracking()
        return instance
    }()

    private func startLocationTracking() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    static func lookUpCoordinate(coordinate: CLLocationCoordinate2D, completionHandler: @escaping (CLPlacemark?)
        -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                completionHandler(firstLocation)
            } else {
                completionHandler(nil)
            }
        }
    }
}

extension LocationManager : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
            inValidState = true
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        inValidState = false
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }
}
