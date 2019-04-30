//
//  PlaylistsViewController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/12/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit

class PlaylistsViewController : UITableViewController {
    var playlists = [API.Playlist]()
    let cellId = "standardCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if let cell = cell as? StandardCell {
            let playlist = playlists[indexPath.row]
            cell.label.text = playlist.name
//            cell.delegate = self
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select row at \(indexPath.row)")
    }
}
