//
//  LibraryViewController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/12/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit
import SwipeCellKit

class LibraryViewController : UITableViewController {
    @IBOutlet weak var settingsButton: UIBarButtonItem!

    let cellId = "standardCell"

    var sections: [(String, () -> Void)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)

        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        settingsButton.title = NSString(string: "\u{2699}\u{0000FE0E}") as String
        if let font = UIFont(name: "Avenir Next", size: 27.0) {
            settingsButton.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        }

        setupSections()
    }

    func setupSections() {
        sections.append(("My Playlists", {
            NavigationManager.showMusicRoomPlaylistsList(from: self, query: nil, onSelection: nil)
        }))
        sections.append(("All Playlists", {
            NavigationManager.showMusicRoomPlaylistsList(from: self, query: "", onSelection: nil)
        }))
        sections.append(("Find User", {
            NavigationManager.findUser(from: self)
        }))
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if let cell = cell as? StandardCell {
            let section = sections[indexPath.row]
            cell.label.text = section.0
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        sections[indexPath.row].1()
    }

    @IBAction func showSettingsAction(_ sender: Any) {
        let viewController = MusicRoomSettingsViewController.makeFromStoryboard(nameStoryboard: "MusicRoomSettings")
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
