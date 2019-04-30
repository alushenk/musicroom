//
//  MusicRoomManager.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/14/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation
import Moya

struct MusicRoomConstant {
    struct KeyChain {
        static let tokenKey = "MusicRoomTokenKey"
        static let userIdKey = "MusicRoomUserIdKey"
    }
}

class MusicRoomManager {
    var token: String = ""
    var userId: Int32 = -1

    var sessionState: SessionState {
        if token != "" {
            return .connected
        }
        return .disconnected
    }

    var loginResult: LoginResult?

    static let sharedInstance : MusicRoomManager = {
        let instance = MusicRoomManager()
        instance.retrieveToken()
        return instance
    }()
}

extension MusicRoomManager {
    private func save(token: String, userId: Int32) {
        _ = KeyChainManager.save(key: MusicRoomConstant.KeyChain.tokenKey, data: token.data)
        _ = KeyChainManager.save(key: MusicRoomConstant.KeyChain.userIdKey, data: userId.data)
    }

    private func retrieveToken() {
        guard let token = String(data: KeyChainManager.load(key: MusicRoomConstant.KeyChain.tokenKey) ?? Data()),
            let userIdString = String(data: KeyChainManager.load(key: MusicRoomConstant.KeyChain.userIdKey) ?? Data()),
            let userId = Int32(userIdString) else {
                clearToken()
                return
        }
        self.token = token
        self.userId = userId
    }

    private func clearToken() {
        KeyChainManager.delete(key: MusicRoomConstant.KeyChain.userIdKey)
        KeyChainManager.delete(key: MusicRoomConstant.KeyChain.tokenKey)
    }
}

extension MusicRoomManager {
    func musicRoomDidLogin(token: String, userId: Int32) {
        save(token: token, userId: userId)
        loginResult?(.success)
        self.token = token
        self.userId = userId
    }

    func musicRoomDidNotLogin(_ cancelled: Bool) {
        let musicRoomError: Error? = cancelled ? nil : NSError.instance(type: .noConnection)
        loginResult?(.error(error: musicRoomError))
    }

    func musicRoomDidLogout(){
        clearToken()
        loginResult?(.logout)
    }
}
