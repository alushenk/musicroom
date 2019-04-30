//
//  UserModel.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/13/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation

extension API {

struct User: Decodable {
    let id: Int32
    let username: String
    let email: String
    let first_name: String
    let last_name: String
}

}
