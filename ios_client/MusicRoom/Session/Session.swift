//
//  Session.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/10/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation

enum ResultLogin {
    case success
    case logout
    case error(error: Error?)
}

typealias LoginResult = ((_ result: ResultLogin) -> ())

enum SessionState {
    case connected
    case disconnected
}
