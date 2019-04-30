//
//  File.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/14/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation

struct DeezerObject {

    let title: String
    let type: DeezerObjectType
    var object: DZRObject?

    init(title: String, type: DeezerObjectType, object: DZRObject? = nil) {
        self.title = title
        self.type = type
        self.object = object
    }
}
