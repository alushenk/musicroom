//
//  NavigationManager+Auth.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/15/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation

extension NavigationManager {
    static func presentMusicRoomAuth(from viewController: UIViewController) {
        let identifier = "MusicRoomAuthEntryViewController"
        let authViewController = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: identifier)
        authViewController.modalTransitionStyle = .crossDissolve
        viewController.present(authViewController, animated: true, completion: nil)
    }
}
