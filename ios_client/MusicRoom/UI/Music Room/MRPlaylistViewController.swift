//
//  MusicRoomPlaylist.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/15/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit
import CoreLocation
import NotificationBannerSwift

class MusicRoomPlaylistViewController : UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var infoStackView: UIStackView!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var infoButton: UIButton!

    private var dataStateController: DataStateController?

    private let cellId = "trackCell"

    var shortPlaylist: API.Playlist?
    private var playlist: API.PlaylistDetailed?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)

        if let playlist = shortPlaylist {
            dataStateController = DataStateController(urlString: "wss://musicroom.ml/ws/playlist/\(playlist.id)/", delegate: self)
        }

        setupSettingsButton()
        loadPlaylist()
    }

    private func validLocation(playlist: API.Playlist, userLocation: CLLocation?) -> Bool {
        guard let place = playlist.place else { return true }

        let userId = MusicRoomManager.sharedInstance.userId
        if playlist.creator != userId && !playlist.owners.contains(userId) {
            if let userLocation = userLocation {
                let playlistLocation = CLLocation(latitude: place.lat, longitude: place.lon)
                if userLocation.distance(from: playlistLocation) > place.radius {
                    setupTooFarAppearence()
                    return false
                }
            } else {
                setupErrorAppearence(message: "Failed to get your location")
                return false
            }
        }

        return true
    }

    @objc private func loadPlaylist(completion: (() -> Void)? = nil) {
        guard let shortPlaylist = shortPlaylist,
            validLocation(playlist: shortPlaylist, userLocation: LocationManager.sharedInstance.location) else { return }

        tableView.isHidden = false
        playlist = nil

        provider.request(.getPlaylist(id: shortPlaylist.id)) { result in
            processMoyaResult(result: result, onSuccess: { data in
                if let playlistObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                    let playlist = API.PlaylistDetailed(jsonObject: playlistObject) {
                    self.playlist = playlist
                    self.shortPlaylist = API.Playlist(detailedPlaylist: playlist)
                    self.title = playlist.name
                    self.tableView.reloadData()
                    completion?()
                } else {
                    UIViewController.present(title: "Failed to load playlist", message: nil, style: .danger)
                    self.setupErrorAppearence(message: "Something went wrong.")
                }
            }, onFailure: { message in
                UIViewController.present(title: "Failed to load playlist", message: message, style: .danger)
                self.setupErrorAppearence(message: message ?? "Something went wrong.")
            })
        }
    }

    private func setupErrorAppearence(message: String) {
        tableView.isHidden = true
        infoLabel.text = message
        infoButton.setImage(UIImage(named: "refresh"), for: .normal)
        infoButton.removeTarget(nil, action: nil, for: .allEvents)
        infoButton.addTarget(self, action: #selector(self.loadPlaylist), for: .touchUpInside)
    }

    private func setupTooFarAppearence() {
        tableView.isHidden = true
        infoLabel.text = "You are too far from playlist location"
        infoButton.setImage(UIImage(named: "ugandan-knuckles"), for: .normal)
        infoButton.removeTarget(nil, action: nil, for: .allEvents)
        infoButton.addTarget(self, action: #selector(self.showRouteToPlaylist), for: .touchUpInside)
    }

    private func setupSettingsButton() {
        let settingsButton = UIBarButtonItem(title: "\u{2022}\u{2022}\u{2022}", style: .plain, target: self, action: #selector(self.showSettings(_:)))
        var attributes: [NSAttributedString.Key : Any] = [:]
        attributes[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 20)
        settingsButton.setTitleTextAttributes(attributes, for: .normal)
        self.navigationItem.rightBarButtonItem = settingsButton
    }

    @objc private func showSettings(_ sender: Any) {
        if let playlist = playlist {
            NavigationManager.showMusicRoomPlaylistSettings(from: self, playlist: playlist)
        } else if let playlist = shortPlaylist {
            NavigationManager.showMusicRoomPlaylistSettings(from: self, playlist: playlist)
        }
    }

    @objc private func showRouteToPlaylist() {
        guard let place = shortPlaylist?.place else { return }

        let coordinate = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon)
        NavigationManager.showRoute(from: self, destinationCoordinate: coordinate)
    }
}

extension MusicRoomPlaylistViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist?.tracks.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if let cell = cell as? TrackCell,
            let track = playlist?.tracks[indexPath.row] {
            cell.songNameLabel.text = track.data.title
            cell.artistAlbumLabel.text = "\(track.data.artist.name) • \(track.data.album.title)"
            cell.settingsButtonAction = {
                guard let playlist = self.playlist else { return }

                var settingItems: [SettingsItem] = []
                if playlist.creator == MusicRoomManager.sharedInstance.userId ||
                    playlist.owners.contains(MusicRoomManager.sharedInstance.userId) {
                    settingItems.append(SettingsItem(title: "Delete", didSelected: { [weak self] in
                        guard let strongSelf = self, let playlist = strongSelf.playlist else { return true }

                        self?.askForConfirmation(actionTitle: "Delete track", onConfirm: {
                            provider.request(.deleteTrack(trackId: track.id), completion: { result in
                                processMoyaResult(result: result, onSuccess: { _ in
                                    UIViewController.present(title: "Successfully deleted track", message: track.data.title)
                                }, onFailure: { _ in
                                    // ignored
                                })
                            })
                        }, onCancel: nil)

                        return true
                    }))
                }
                let track = playlist.tracks[indexPath.row]
                let voteTitle = track.votes.contains(where: { vote in
                    return vote.user_id == MusicRoomManager.sharedInstance.userId
                }) ? "Unvote" : "Vote"
                settingItems.append(SettingsItem(title: voteTitle, didSelected: {
                    provider.request(.vote(trackId: track.id), completion: { result in
                        let title = voteTitle.lowercased()
                        processMoyaResult(result: result, onSuccess: { data in
                            UIViewController.present(title: "Successfully \(title)d track", message: track.data.title)
                        }, onFailure: { message in
                            UIViewController.present(title: "Failed to \(title) track", message: message, style: .danger)
                        })
                    })
                    return true
                }))
                NavigationManager.showListOf(items: settingItems, fromViewController: self)
            }
        }
        return cell
    }
}

extension MusicRoomPlaylistViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let playlist = self.playlist else { return }
        NavigationManager.showDeezerPlayer(from: self, playable: DeezerTracks(with: playlist, startIndex: indexPath.row), index: indexPath.row, voteController: VoteController(with: playlist))
    }
}

extension MusicRoomPlaylistViewController : DataStateDelegate {
    func refreshData() {
        self.loadPlaylist {
            self.navigationController?.popToViewController(self, animated: true)
        }
    }

    func removeData() {
        if let viewControllers = self.navigationController?.viewControllers,
            let currentIndex = viewControllers.firstIndex(of: self),
            currentIndex + 1 < viewControllers.count {
            if let dataStateDelegate = viewControllers[currentIndex + 1] as? DataStateDelegate {
                dataStateDelegate.removeData()
            }
        }
        UIViewController.present(title: "Playlist has been deleted")
        if let viewControllers = self.navigationController?.viewControllers,
            let currentIndex = viewControllers.firstIndex(of: self),
            currentIndex != 0 {
            self.navigationController?.popToViewController(viewControllers[currentIndex - 1], animated: true)
        }
    }
}
