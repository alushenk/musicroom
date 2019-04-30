//
//  NavigationManager+Map.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 2019-04-25.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation
import CoreLocation

extension NavigationManager {
    static func showRoute(from viewController: UIViewController, destinationCoordinate: CLLocationCoordinate2D?) {
        guard let routeVC = RouteViewController.makeFromStoryboard(nameStoryboard: "Map") as? RouteViewController else { return }
        routeVC.destinationCoordinate = destinationCoordinate
        viewController.navigationController?.pushViewController(routeVC, animated: true)
    }

    static func showSelectLocationViewController(from viewController: UIViewController, currentPlace: API.Place?, completion: @escaping (API.Place) -> Void) {
        guard let selectLocationVC = SelectLocationViewController.makeFromStoryboard(nameStoryboard: "Map") as? SelectLocationViewController else {
            return
        }
        selectLocationVC.completion = completion
        selectLocationVC.initialPlace = currentPlace
        viewController.navigationController?.pushViewController(selectLocationVC, animated: true)
    }
}
