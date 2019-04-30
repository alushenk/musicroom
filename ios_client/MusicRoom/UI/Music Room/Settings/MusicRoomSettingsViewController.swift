//
//  MusicRoomSettings.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/15/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit

struct SectionEntry {
    let title: String
    let viewController: () -> UIViewController?
}

class MusicRoomSettingsViewController : UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private lazy var sectionArray: [SectionEntry] = {
        var _sectionArray = [SectionEntry]()
        _sectionArray.append(SectionEntry(title: "Profile", viewController: {
            return MusicRoomAccountViewController.makeFromStoryboard(nameStoryboard: "MusicRoomSettings")}))
        _sectionArray.append(SectionEntry(title: "Deezer", viewController: {
            return MusicRoomDeezerSettingsViewController.makeFromStoryboard(nameStoryboard: "MusicRoomSettings")}))
        _sectionArray.append(SectionEntry(title: "About", viewController: {
            return MusicRoomAboutViewController.makeFromStoryboard(nameStoryboard: "MusicRoomSettings")}))
        return _sectionArray
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        setupTableView()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }

    @IBAction func logOutAction(_ sender: Any) {
        MusicRoomManager.sharedInstance.musicRoomDidLogout()
        NavigationManager.presentMusicRoomAuth(from: self)
    }
}

extension MusicRoomSettingsViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = sectionArray[indexPath.row].title
        return cell
    }
}

extension MusicRoomSettingsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let viewController = sectionArray[indexPath.row].viewController() {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
