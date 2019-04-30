//
//  DeezerTrackSettingsViewController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 2019-04-26.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation

class DeezerTrackSettingsViewController : UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let cellId = "standardCell"

    private var settingsSections: [(String, (() -> Void)?)] = []

    var track: DZRTrack?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()

        guard let track = track else { return }

        settingsSections.append(("Add to playlist", {

        }))
    }
}
