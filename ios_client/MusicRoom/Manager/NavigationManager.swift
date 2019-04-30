//
//  NavigationManager.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/14/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation

struct NavigationManager {

    static func showViewControllerOfType(from viewController: UIViewController, type: Any.Type, storyboard: String) {
        let identifier = String(describing: type)
        let viewController = UIStoryboard(name: storyboard, bundle: Bundle.main).instantiateViewController(withIdentifier: identifier)
        viewController.navigationController?.pushViewController(viewController, animated: true)
    }

    static func showMusicRoomSession(from viewController: UIViewController) {

    }
}
