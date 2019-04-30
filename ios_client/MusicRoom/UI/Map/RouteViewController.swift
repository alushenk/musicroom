//
//  RouteViewController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 2019-04-25.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit
import MapKit

class RouteViewController : UIViewController {
    @IBOutlet private weak var mapView: MKMapView!

    var destinationCoordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

        guard let destinationCoordinate = destinationCoordinate else { return }

        var annotations: [MKAnnotation] = []
        let createPlaceMark: (CLLocationCoordinate2D?) -> MKPlacemark? = { coordinate in
            guard let coordinate = coordinate else { return nil }

            let placemark = MKPlacemark(coordinate: coordinate)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            LocationManager.lookUpCoordinate(coordinate: coordinate) { placemark in
                guard let placemark = placemark else { return }

                annotation.title = placemark.name
                if let city = placemark.locality,
                    let state = placemark.administrativeArea {
                    annotation.subtitle = "\(city) \(state)"
                }
            }
            annotations.append(annotation)

            return placemark
        }

        let sourcePlacemark = createPlaceMark(LocationManager.sharedInstance.location?.coordinate)
        let destinationPlacemark = createPlaceMark(destinationCoordinate)

        if annotations.count > 0 {
            self.mapView.showAnnotations(annotations, animated: true)
        }

        if let sourcePlacemark = sourcePlacemark,
            let destinationPlacemark = destinationPlacemark {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: sourcePlacemark)
            request.destination = MKMapItem(placemark: destinationPlacemark)
            request.requestsAlternateRoutes = true
            request.transportType = .automobile

            let directions = MKDirections(request: request)
            directions.calculate { [weak self] response, error in
                guard let strongSelf = self else { return }

                if let response = response,
                    !response.routes.isEmpty {
                    strongSelf.mapView.addOverlay(response.routes[0].polyline)
                    var rect = response.routes[0].polyline.boundingMapRect
                    let scale = 1.25
                    rect.origin.x -= rect.size.width * (scale - 1.0) * 0.5
                    rect.origin.y -= rect.size.height * (scale - 1.0) * 0.5
                    rect.size.width *= scale
                    rect.size.height *= scale
                    strongSelf.mapView.setVisibleMapRect(rect, animated: true)
                } else {
                    UIViewController.present(title: "Could not find a route", message: nil, style: .danger)
                }
            }
        } else if destinationPlacemark != nil {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: destinationCoordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
}

extension RouteViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = self.view.tintColor
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return MKPolylineRenderer()
    }
}
