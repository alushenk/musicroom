//
//  DeezerTrackOption.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 2019-04-26.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation

class DeezerTrackOption : ListItem {
    private static let cellId = "cell"
    private let track: DZRTrack
    private let option: String
    private let didSelected: () -> Bool

    init(track: DZRTrack, option: String, didSelected: @escaping () -> Bool) {
        self.track = track
        self.option = option
        self.didSelected = didSelected
    }

    func onSelection() -> Bool {
        return didSelected()
    }

    func cell(for tableView: UITableView) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: DeezerTrackOption.cellId)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: DeezerTrackOption.cellId)
        }

        cell?.textLabel?.text = option
        return cell!
    }
}
