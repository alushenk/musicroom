//
//  editPlaylistCell.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/20/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit

class EditPlaylistCell : UITableViewCell {
    @IBOutlet weak var playlistName: UILabel!
    var deleteAction: (() -> Void)?

    @IBAction func deleteButtonAction(_ sender: Any) {
        deleteAction?()
    }
}
