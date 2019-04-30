//
//  DeezerObjectListViewController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/14/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit

class DeezerObjectListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private let trackCellId = "trackCell"

    private var data: [Any]? {
        didSet {
            tableViewDelegate?.data = data
        }
    }
    private var deezerObjectList: DZRObjectList? {
        didSet {
            getData()
        }
    }

    private var tableViewDelegate: DeezerObjectTableViewDelegate?
    var object: DeezerObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = object?.title
        setupTableView()
        getObjectList()
    }

    func getObjectList() {
        guard let type = self.object?.type else {
            return
        }


        type.getObjectList(object: object?.object, callback: { [weak self] (deezerObjectList, error) in
            guard let deezerObjectList = deezerObjectList, let strongSelf = self else {
                print(error.debugDescription )
                return
            }
            strongSelf.deezerObjectList = deezerObjectList
        })
    }

    func getData() {
        guard let objectList = self.deezerObjectList else {
            return
        }
        DeezerManager.sharedInstance.getData(fromObjectList: objectList) {[weak self] (data, error) in
            guard let data = data, let strongSelf = self else {
                if let error = error {
                    UIViewController.present(title: "Failed to get deezer data", error: error)
                }
                return
            }

            strongSelf.data = data
            strongSelf.tableView.reloadData()
        }
    }

    func setupTableView() {
        tableViewDelegate = DeezerObjectTableViewDelegate(viewController: self, object: object)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "default")
        tableView.register(UINib(nibName: trackCellId, bundle: nil), forCellReuseIdentifier: trackCellId)
        tableView.delegate = tableViewDelegate
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 50
    }
}

// MARK: - UITableViewDataSource

extension DeezerObjectListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dzrObject = data?[indexPath.row] as? DZRObject else {
            return UITableViewCell()
        }

        if let track = dzrObject as? DZRTrack {
            let cell = tableView.dequeueReusableCell(withIdentifier: trackCellId, for: indexPath)
            if let cell = cell as? TrackCell {
                cell.settingsButtonAction = {
                    NavigationManager.showListOf(items: [
                        DeezerTrackOption(track: track, option: "Add to Playlist", didSelected: { [weak self] in
                            guard let strongSelf = self else { return false }
                            NavigationManager.showMusicRoomPlaylistsList(from: strongSelf, query: nil, onSelection: { playlist in
                                API.DeezerTrackData.load(for: track, completion: { (trackData, error) in
                                    guard let trackData = trackData else {
                                        UIViewController.present(title: "Failed to add track", message: error?.localizedDescription, style: .danger)
                                        return
                                    }

                                    provider.request(.addPlaylistTrack(id: playlist.id, trackData: trackData), completion: { result in
                                        processMoyaResult(result: result, onSuccess: { _ in
                                            UIViewController.present(title: "Successfully added track", message: trackData.title, style: .success)
                                        }, onFailure: { message in
                                            UIViewController.present(title: "Failed to add track", message: message, style: .danger)
                                        })
                                    })
                                })
                                return true
                            })
                            return false
                        })], fromViewController: self)
                }
                DeezerManager.sharedInstance.getData(track: track) { (data, error) in
                    guard let data = data else {
                        if let error = error {
                            UIViewController.present(title: "Failed to get deezer data", error: error)
                        }
                        return
                    }

                    if let title = data[DZRPlayableObjectInfoName] as? String {
                        cell.songNameLabel.text = title
                    }

                    var subTitle = ""

                    if let artist = data[DZRPlayableObjectInfoCreator] as? String {
                        subTitle = artist
                    }
                    if let album = data[DZRPlayableObjectInfoSource] as? String {
                        if subTitle.isEmpty {
                            subTitle = album
                        } else {
                            subTitle = "\(subTitle) • \(album)"
                        }
                    }
                    cell.artistAlbumLabel.text = subTitle
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath)
            cell.textLabel?.text = dzrObject.description
            return cell
        }
    }

}
