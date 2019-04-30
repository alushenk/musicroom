//
//  DeezerObjectTableViewDelegate.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/14/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit

class DeezerObjectTableViewDelegate: NSObject {

    var data: [Any]?
    var object: DeezerObject?
    var viewController: UIViewController?
    var onSelection: ((DZRObject) -> Bool)?

    init(viewController: UIViewController, object: DeezerObject?) {
        self.viewController = viewController
        self.object = object
    }

    private func showViewController(for object: DZRObject, at indexPath: IndexPath) {
        guard let type = self.object?.type, let viewController = viewController else {
            return
        }

        var newObject: DeezerObject!

        switch type {
        case .track:
            if let playable = self.object?.object as? DZRPlayable {
                NavigationManager.showDeezerPlayer(from: viewController, playable: playable, index: indexPath.row)
            } else if let playable = object as? DZRPlayable {
                NavigationManager.showDeezerPlayer(from: viewController, playable: playable, index: indexPath.row)
            }
            return
        case .artist:
            newObject = DeezerObject(title: "Tracks of \(object.description)", type: .album, object: object)
        default:
            newObject = DeezerObject(title: "Albums of \(object.description)", type: .track, object: object)
        }
        NavigationManager.showDeezerObjectList(from: viewController, object: newObject)
    }
}

// MARK: - UITableViewDelegate

extension DeezerObjectTableViewDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let selectedObject = data?[indexPath.row] as? DZRObject else {
            return
        }

        if let onSelection = onSelection {
            if !onSelection(selectedObject) {
                showViewController(for: selectedObject, at: indexPath)
            }
        } else {
            showViewController(for: selectedObject, at: indexPath)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension DeezerObjectTableViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        viewController?.view.endEditing(true)
    }
}
