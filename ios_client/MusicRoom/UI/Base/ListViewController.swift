//
//  ListViewController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 2019-04-26.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation

protocol ListItem {
    func onSelection() -> Bool
    func cell(for tableView: UITableView) -> UITableViewCell
}

class ListViewController : UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var items: [ListItem]?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self

        if items != nil {
            tableView.reloadData()
        }
    }
}

extension ListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let items = items else { return }
        if indexPath.row < items.count,
            items[indexPath.row].onSelection() {
            self.navigationController?.popViewController(animated: true)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension ListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let items = items else { return UITableViewCell() }
        return items[indexPath.row].cell(for: tableView)
    }
}
