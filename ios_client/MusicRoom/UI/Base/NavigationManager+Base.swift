//
//  NavigationManager+UI.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 2019-04-26.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation

extension NavigationManager {
    static func showListOf(items: [ListItem], fromViewController: UIViewController) {
        guard let listVC = ListViewController.makeFromStoryboard(nameStoryboard: "Base") as? ListViewController else { return }
        listVC.items = items
        fromViewController.navigationController?.pushViewController(listVC, animated: true)
    }
}
