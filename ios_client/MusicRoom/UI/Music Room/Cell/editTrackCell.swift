//
//  editTrackCell.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/30/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit

class EditTrackCell : UITableViewCell {
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    var deleteAction: (() -> Void)?

    @IBAction func deleteButtonAction(_ sender: Any) {
        deleteAction?()
    }
}

