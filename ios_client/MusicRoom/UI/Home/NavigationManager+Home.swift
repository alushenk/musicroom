//
//  NavigationManager+Home.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/15/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation

extension NavigationManager {
    static func presentMusicRoomHome(from viewController: UIViewController) {
        guard let homeViewController = HomeTabBarController.makeFromStoryboard(nameStoryboard: "Home") as? HomeTabBarController else {
            return
        }
        homeViewController.modalTransitionStyle = .crossDissolve
        viewController.present(homeViewController, animated: true, completion: nil)
    }
}
