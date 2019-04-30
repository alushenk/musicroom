//
//  MusicRoomPlaylistListViewController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/15/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit

extension API {

struct PlaylistCreationResponse : Decodable {
    let id: Int32
    let name: String
    let is_public: Bool
    let is_active: Bool
    let place: String?
    let time_from: String?
    let time_to: String?
}

}

class MusicRoomPlaylistListViewController : UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    private var dataStateController: DataStateController?

    private var editPlaylistsButton: UIBarButtonItem?
    private var createPlaylistButton: UIBarButtonItem?

    private var searchBar : UISearchBar?

    var query: String?
    var onSelection: ((API.Playlist) -> Bool)?

    private var playlists: [API.Playlist]?
    private var showedPlaylists: [API.Playlist]?

    private let defaultCellId = "playlistCell"
    private let editCellId = "editPlaylistCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: editCellId, bundle: nil), forCellReuseIdentifier: editCellId)
        tableView.register(UINib(nibName: defaultCellId, bundle: nil), forCellReuseIdentifier: defaultCellId)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()

        if query != nil {
            self.searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
            self.searchBar?.delegate = self
            self.searchBar?.placeholder = "Search Playlist"
            tableView.tableHeaderView = self.searchBar
        } else {
            dataStateController = DataStateController(urlString: "wss://musicroom.ml/ws/user/\(MusicRoomManager.sharedInstance.userId)/", delegate: self)

            editPlaylistsButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.editPlaylistsAction))
            editPlaylistsButton?.isEnabled = true
            editPlaylistsButton?.tintColor = self.view.tintColor
            self.navigationItem.rightBarButtonItem = editPlaylistsButton

            createPlaylistButton = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(self.createPlaylistAction))
            createPlaylistButton?.isEnabled = false
            createPlaylistButton?.tintColor = .clear

            self.navigationItem.leftItemsSupplementBackButton = false
        }

        search(query)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar?.endEditing(false)
        definesPresentationContext = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        definesPresentationContext = false
    }

    func inDefaultMode() -> Bool {
        return query != nil || editPlaylistsButton?.title == "Edit"
    }

    func loadPlaylists(with completion: @escaping () -> Void) {
        let target: MusicRoomService = query != nil ?
            .getPlaylists :
            .getPlaylistsOf(userId: MusicRoomManager.sharedInstance.userId)

        provider.request(target) { result in
            switch result {
            case let .success(response):
                if let playlists = try? JSONDecoder().decode([API.Playlist].self, from: response.data) {
                    self.playlists = playlists
                    completion()
                }

            case let .failure(error):
                print("Error occured: \(error)")
            }
        }
    }

    func search(_ query: String?) {
        if let playlists = playlists {
            if let query = query {
                if query == "" {
                    showedPlaylists = playlists
                } else {
                    showedPlaylists = playlists.filter({ playlist in
                        return playlist.name.localizedCaseInsensitiveContains(query)
                    })
                }
            } else {
                showedPlaylists = playlists
            }

            self.tableView.reloadData()
        } else {
            loadPlaylists {
                self.search(query)
            }
        }
    }

    func clearData() {
        self.playlists = nil
        self.showedPlaylists = nil
        tableView.reloadData()
    }

    @objc func editPlaylistsAction(_ sender: Any) {
        if inDefaultMode() {
            editPlaylistsButton?.title = "Done"
            tableView.allowsSelection = false

            self.navigationItem.leftBarButtonItem = createPlaylistButton
            createPlaylistButton?.isEnabled = true
            UIView.animate(withDuration: 0.5, animations: {
                self.createPlaylistButton?.tintColor = self.view.tintColor
            })
        } else {
            editPlaylistsButton?.title = "Edit"
            tableView.allowsSelection = true

            UIView.animate(withDuration: 0.5, animations: {
                self.createPlaylistButton?.tintColor = UIColor.clear
            }) { success in
                self.createPlaylistButton?.isEnabled = false
                self.navigationItem.leftBarButtonItem = nil
            }
        }

        tableView.reloadSections(IndexSet(integersIn: 0...0), with: .fade)
    }

    @objc func createPlaylistAction(_ sender: Any) {
        let alertController = UIAlertController(title: "New Playlist Name", message: nil, preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Enter name"
        }

        let createAction = UIAlertAction(title: "Create", style: .default) { _ in
            if let name = alertController.textFields?[0].text {
                provider.request(.createPlaylist(name: name), completion: { result in
                    processMoyaResult(result: result, onSuccess: nil, onFailure: { message in
                        UIViewController.present(title: "Failed to create playlist", message: message, style: .danger)
                    })
                })
            }
        }
        alertController.addAction(createAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
}

extension MusicRoomPlaylistListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let playlist = self.showedPlaylists?[indexPath.row] {
            if let onSelection = onSelection {
                if onSelection(playlist) {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                NavigationManager.showMusicRoomPlaylist(from: self, playlist: playlist)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MusicRoomPlaylistListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showedPlaylists?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if inDefaultMode() {
            let cell = tableView.dequeueReusableCell(withIdentifier: defaultCellId, for: indexPath)
            if let cell = cell as? PlaylistCell,
                let playlist = showedPlaylists?[indexPath.row] {
                cell.playlistNameLabel.text = playlist.name
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: editCellId, for: indexPath)
            if let cell = cell as? EditPlaylistCell,
                let playlist = showedPlaylists?[indexPath.row] {
                cell.playlistName.text = playlist.name
                cell.deleteAction = {
                    var title: String
                    var target: MusicRoomService
                    if playlist.creator == MusicRoomManager.sharedInstance.userId {
                        title = "Delete Playlist"
                        target = .deletePlaylist(id: playlist.id)
                    } else {
                        title = "Stop Following Playlist"
                        target = .unfollowPlaylist(id: playlist.id)
                    }

                    self.askForConfirmation(actionTitle: title, onConfirm: {
                        provider.request(target, completion: { result in
                            processMoyaResult(result: result, onSuccess: { _ in
                                UIViewController.present(title: "\"\(title)\" - success", message: playlist.name)
                            }, onFailure: { message in
                                if playlist.creator == MusicRoomManager.sharedInstance.userId {
                                    UIViewController.present(title: "\"\(title)\" - fail", message: message, style: .danger)
                                }
                            })
                        })
                    }, onCancel: nil)
                }
            }
            return cell
        }
    }
}

extension MusicRoomPlaylistListViewController : UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.query = searchText
        search(self.query)
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = false
        return true
    }
}

extension MusicRoomPlaylistListViewController : DataStateDelegate {
    func refreshData() {
        self.playlists = nil
        search(self.query)
    }

    func removeData() {
        print("Socket(My playlists) - removeData called")
    }
}
