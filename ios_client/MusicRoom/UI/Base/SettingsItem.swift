//
//  SettingsItem.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/27/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation

class SettingsItem : ListItem {
    private static let cellId = "cell"
    private let title: String
    private let didSelected: () -> Bool

    init(title: String, didSelected: @escaping () -> Bool) {
        self.title = title
        self.didSelected = didSelected
    }

    func onSelection() -> Bool {
        return didSelected()
    }

    func cell(for tableView: UITableView) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: SettingsItem.cellId)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: SettingsItem.cellId)
        }

        cell?.textLabel?.text = title
        return cell!
    }
}
