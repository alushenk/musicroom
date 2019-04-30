//
//  MusicRoomAboutViewController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/16/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit

class MusicRoomAboutViewController : UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private let cellId = "keyValueCell"

    private let infoArray = [
        ("Version", "0.01a")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About"

        tableView.register(UINib(nibName: cellId, bundle: Bundle.main), forCellReuseIdentifier: cellId)
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
}

extension MusicRoomAboutViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "keyValueCell", for: indexPath)
        if let cell = cell as? KeyValueCell {
            cell.keyLabel.text = infoArray[indexPath.row].0
            cell.valueLabel.text = infoArray[indexPath.row].1
        }
        return cell
    }
}
