//
//  HomeDeezerViewController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/19/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit

class HomeDeezerViewController : UIViewController {
    @IBOutlet weak var unauthorizedStackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!

    private lazy var typeArray: [DeezerObject] = {
        var _typeArray = [DeezerObject]()
        _typeArray.append(DeezerObject(title: "Tracks", type: .track))
        _typeArray.append(DeezerObject(title: "Albums", type: .album))
        _typeArray.append(DeezerObject(title: "Artists", type: .artist))
        _typeArray.append(DeezerObject(title: "Playlists", type: .playlist))
        _typeArray.append(DeezerObject(title: "Mixes", type: .mix))
        return _typeArray
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupDefaultUI()
    }

    func setupDefaultUI() {
        self.tableView.isHidden = false
        self.unauthorizedStackView.isHidden = true
    }


    @IBAction func goToSettingsAction(_ sender: Any) {
        NavigationManager.showMusicRoomSettings(from: self)
    }
}

extension HomeDeezerViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        NavigationManager.showDeezerSearch(from: self, type: typeArray[indexPath.row].type)
    }
}

extension HomeDeezerViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = typeArray[indexPath.row].title
        return cell
    }
}

