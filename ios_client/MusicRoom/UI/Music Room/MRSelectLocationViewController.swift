//
//  SelectLocationViewController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 2019-04-23.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch: class {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class SelectLocationViewController : UIViewController {
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var showMyLocationButton: UIButton!
    
    private var resultSearchController: UISearchController?
    private var selectedPin: MKPlacemark?
    private var placeCircle: MKCircle?

    private var circleIsAllowedToResize = true
    private var circleOriginalWorldRadius = 0.0

    var completion: ((API.Place) -> Void)?
    var initialPlace: API.Place?

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        setupAddressSearchControllers()
        setupGestureRecognizers()

        showMyLocationButton.isEnabled = LocationManager.sharedInstance.inValidState
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        definesPresentationContext = true

        if let initialPlace = initialPlace {
            let initialCoordinate = CLLocationCoordinate2D(latitude: initialPlace.lat, longitude: initialPlace.lon)
            setMapPin(atCoordinate: initialCoordinate)
            setMapCircle(coordinate: initialCoordinate, radius: initialPlace.radius)
            showMap(atCoordinate: initialCoordinate)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        definesPresentationContext = false
    }

    private func setupGestureRecognizers() {
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: nil)
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        mapView.addGestureRecognizer(doubleTapRecognizer)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.mapTapAction(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.require(toFail: doubleTapRecognizer)
        mapView.addGestureRecognizer(tapRecognizer)

        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.mapPanAction(_:)))
        panRecognizer.delegate = self
        mapView.addGestureRecognizer(panRecognizer)
    }

    private func setupAddressSearchControllers() {
        let locationSearchVC = LocationSearchViewController.makeFromStoryboard(nameStoryboard: "Map") as? LocationSearchViewController
        resultSearchController = UISearchController(searchResultsController: locationSearchVC)
        resultSearchController?.searchResultsUpdater = locationSearchVC
        if let searchBar = resultSearchController?.searchBar {
            searchBar.sizeToFit()
            searchBar.placeholder = "Search for places"
            navigationItem.titleView = resultSearchController?.searchBar
            resultSearchController?.hidesNavigationBarDuringPresentation = false
            resultSearchController?.dimsBackgroundDuringPresentation = true
        }
        if let locationSearchVC = locationSearchVC {
            locationSearchVC.mapView = mapView
            locationSearchVC.handleMapSearchDelegate = self
        }
    }

    @objc private func mapPanAction(_ sender: Any) {
        guard let panRecognizer = sender as? UIPanGestureRecognizer,
            let circle = placeCircle else { return }

        switch panRecognizer.state {
        case .began:
            let point = panRecognizer.location(in: mapView)
            let tapCoordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let tapLocation = CLLocation(latitude: tapCoordinate.latitude, longitude: tapCoordinate.longitude)

            let originalCoordinate = circle.coordinate
            let originalLocation = CLLocation(latitude: originalCoordinate.latitude, longitude: originalCoordinate.longitude)

            if tapLocation.distance(from: originalLocation) > circle.radius {
                mapView.isScrollEnabled = true
                circleIsAllowedToResize = false
            } else {
                circleOriginalWorldRadius = circle.radius
                circleIsAllowedToResize = true
                mapView.isScrollEnabled = false
            }
        case .changed:
            if !circleIsAllowedToResize {
                return
            }
            let translation = panRecognizer.translation(in: panRecognizer.view)
            let newPoint = panRecognizer.location(in: panRecognizer.view)
            let resizeStartPoint = newPoint - translation
            let centerPoint = mapView.convert(circle.coordinate, toPointTo: panRecognizer.view)

            let radialDir = (newPoint - centerPoint).normalized()
            let radiusDelta = radialDir.dot(translation)
            let radius = resizeStartPoint.distanceTo(centerPoint)

            var newRadius = radius + radiusDelta
            if newRadius < 0.0 {
                newRadius *= -1.0
            }

            let radiusScale = newRadius / radius
            let worldRadius = max(circleOriginalWorldRadius * Double(radiusScale), 25.0)

            setMapCircle(coordinate: circle.coordinate, radius: worldRadius)
        default:
            mapView.isScrollEnabled = true
            circleIsAllowedToResize = false
        }
    }

    @objc private func mapTapAction(_ sender: Any) {
        guard let tapRecognizer = sender as? UITapGestureRecognizer,
            tapRecognizer.state == .ended else {
            return
        }

        if mapView.selectedAnnotations.count == 0 {
            let coordinate = mapView.convert(tapRecognizer.location(in: mapView), toCoordinateFrom: mapView)
            setMapPin(atCoordinate: coordinate)
            setMapCircle(coordinate: coordinate, radius: placeCircle?.radius ?? 500.0)
        } else {
            for annotation in mapView.selectedAnnotations {
                mapView.deselectAnnotation(annotation, animated: true)
            }
        }
    }

    private func setMapPin(atCoordinate: CLLocationCoordinate2D) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.setCenter(atCoordinate, animated: true)

        selectedPin = MKPlacemark(coordinate: atCoordinate)
        let annotation = MKPointAnnotation()
        annotation.coordinate = atCoordinate
        annotation.title = "Location"
        LocationManager.lookUpCoordinate(coordinate: atCoordinate) { placemark in
            guard let placemark = placemark else { return }

            annotation.title = placemark.name

            if let city = placemark.locality,
                let state = placemark.administrativeArea {
                annotation.subtitle = "\(city) \(state)"
            }
        }

        mapView.addAnnotation(annotation)
    }

    private func setMapCircle(coordinate: CLLocationCoordinate2D, radius: Double) {
        if let placeCircle = placeCircle {
            self.mapView.removeOverlay(placeCircle)
        }

        let circle = MKCircle(center: coordinate, radius: radius)
        self.placeCircle = circle

        self.mapView.addOverlay(circle)
    }

    @IBAction private func showCurrentLocation(_ sender: Any) {
        if let location = LocationManager.sharedInstance.location {
            setMapPin(atCoordinate: location.coordinate)
            setMapCircle(coordinate: location.coordinate, radius: placeCircle?.radius ?? 500.0)
            showMap(atCoordinate: location.coordinate)
        } else {
            UIViewController.present(title: "Failed to show current location", message: nil, style: .danger)
            self.showMyLocationButton.isEnabled = false
        }
    }

    private func showMap(atCoordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: atCoordinate, span: span)
        mapView.setRegion(region, animated: true)
    }

    @objc private func didSelectLocation(_ sender: Any) {
        if let completion = completion,
            let coordinate = self.selectedPin?.coordinate,
            let circle = placeCircle {
            completion(API.Place(lon: coordinate.longitude, lat: coordinate.latitude, radius: circle.radius))
        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension SelectLocationViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let userLocationView = mapView.view(for: userLocation) {
            userLocationView.canShowCallout = false
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        let reuseId = "marker"
        var markerView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        if markerView == nil {
            markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }

        markerView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
        button.setTitle("\u{2714}", for: .normal)
        button.addTarget(self, action: #selector(self.didSelectLocation(_:)), for: .touchUpInside)
        markerView?.leftCalloutAccessoryView = button

        return markerView
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = .red
            circle.fillColor = .red
            circle.alpha = 0.2
            circle.lineWidth = 1
            return circle
        } else {
            return MKOverlayRenderer()
        }
    }
}

extension SelectLocationViewController : HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark){
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)

        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name

        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }

        mapView.addAnnotation(annotation)
        showMap(atCoordinate: placemark.coordinate)
    }
}

extension SelectLocationViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer
    }
}
