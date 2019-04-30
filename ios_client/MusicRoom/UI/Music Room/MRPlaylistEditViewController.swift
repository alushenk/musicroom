//
//  MRPlaylistEditViewControll.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/30/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit

class MRPlaylistEditViewController : UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let cellId = "editTrackCell"

    @IBOutlet private weak var playlistNameTextField: UITextField!

    var playlist: API.PlaylistDetailed?

    private var tracks: [API.PlaylistTrack] = []
    private var deletedTracks: [Int32] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)

        if let playlist = playlist {
            playlistNameTextField.text = playlist.name

            tracks = playlist.tracks
        }

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelAction))
        cancelButton.tintColor = self.view.tintColor
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.leftItemsSupplementBackButton = false

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneAction))
        doneButton.tintColor = self.view.tintColor
        self.navigationItem.rightBarButtonItem = doneButton
    }

    @objc private func cancelAction() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func doneAction() {
        guard let playlist = playlist else { return }

        if let newName = playlistNameTextField.text,
            playlist.name != newName {
            provider.request(.setPlaylistName(id: playlist.id, name: newName)) { result in
                processMoyaResult(result: result, onSuccess: { _ in
                    UIViewController.present(title: "Successfully changed name", message: "New name \(newName)")
                }, onFailure: { message in
                    UIViewController.present(title: "Failed to set playlist name", message: message, style: .danger)
                })
            }
        }

        for id in deletedTracks {
            provider.request(.deleteTrack(trackId: id)) { _ in
                // ignored
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension MRPlaylistEditViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if let cell = cell as? EditTrackCell {
            let track: API.PlaylistTrack = tracks[indexPath.row]
            cell.songNameLabel.text = track.data.title
            cell.albumLabel.text = "\(track.data.artist.name) • \(track.data.album.title)"
            cell.deleteAction = {
                if let trackIndex = self.tracks.firstIndex(where: { searchableTrack in return searchableTrack.id == track.id }) {
                    let indexPath = IndexPath(row: trackIndex, section: 0)
                    self.deletedTracks.append(track.id)
                    self.tracks.remove(at: trackIndex)
                    self.tableView.deleteRows(at: [indexPath], with: .left)
                }
            }
        }
        return cell
    }
}

