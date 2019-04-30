//
//  trackCell.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/24/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit

class TrackCell : UITableViewCell {
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistAlbumLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    var settingsButtonAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        settingsButton.addTarget(self, action: #selector(self.settingsButtonTapped(_:)), for: .touchUpInside)
    }

    @objc private func settingsButtonTapped(_ sender: UIButton) {
        settingsButtonAction?()
    }
}
