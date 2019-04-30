//
//  EntryViewController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/14/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit

class EntryViewController : UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //  Dummy call to instantiate location manager
        let _ = LocationManager.sharedInstance.location

        if MusicRoomManager.sharedInstance.sessionState == .connected {
            NavigationManager.presentMusicRoomHome(from: self)
        } else {
            NavigationManager.presentMusicRoomAuth(from: self)
        }
    }
}
