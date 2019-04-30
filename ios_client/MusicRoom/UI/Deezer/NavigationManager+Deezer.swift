//
//  NavigationManager+Deezer.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/15/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation
import LNPopupController

extension NavigationManager {
    static func showDeezerObjectList(from viewController: UIViewController, object: DeezerObject) {
        guard let newViewController = DeezerObjectListViewController.makeFromStoryboard(nameStoryboard: "Deezer") as? DeezerObjectListViewController else {
            return
        }
        newViewController.object = object
        viewController.navigationController?.pushViewController(newViewController, animated: true)
    }

    static func showDeezerSearch(from viewController: UIViewController, type: DeezerObjectType, onSelection: ((DZRObject) -> Bool)? = nil) {
        guard let searchViewController = DeezerSearchViewController.makeFromStoryboard(nameStoryboard: "Deezer") as? DeezerSearchViewController else {
            return
        }
        searchViewController.type = type
        searchViewController.onSelection = onSelection
        viewController.navigationController?.pushViewController(searchViewController, animated: true)
    }

    static func showDeezerPlayer(from viewController: UIViewController, playable: DZRPlayable, index: Int, voteController: VoteController? = nil) {
        guard let deezerPlayerViewController = DeezerPlayerViewController.makeFromStoryboard(nameStoryboard: "Deezer") as? DeezerPlayerViewController else {
            return
        }
        deezerPlayerViewController.configure(playable: playable, currentIndex: 0, voteController: voteController)
        viewController.tabBarController?.presentPopupBar(withContentViewController: deezerPlayerViewController, animated: true, completion: nil)
        viewController.tabBarController?.popupBar.imageView.layer.cornerRadius = 5
    }
}
