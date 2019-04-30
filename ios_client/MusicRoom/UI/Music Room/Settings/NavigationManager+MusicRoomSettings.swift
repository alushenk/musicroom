//
//  NavigationManager+MusicRoomSettings.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/17/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation

extension NavigationManager {
    static func showMusicRoomSettings(from viewController: UIViewController) {
        guard let settingsViewController = MusicRoomSettingsViewController.makeFromStoryboard(nameStoryboard: "MusicRoomSettings") as? MusicRoomSettingsViewController else {
            return
        }
        viewController.navigationController?.pushViewController(settingsViewController, animated: true)
    }

    static func showUserAccount(from viewController: UIViewController, userId: Int32?) {
        guard let userAccVC = MusicRoomAccountViewController.makeFromStoryboard(nameStoryboard: "MusicRoomSettings") as? MusicRoomAccountViewController else {
            return
        }
        userAccVC.userId = userId
        viewController.navigationController?.pushViewController(userAccVC, animated: true)
    }
}
