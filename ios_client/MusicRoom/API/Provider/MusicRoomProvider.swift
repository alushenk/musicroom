//
//  MusicRoomProvider.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 2019-03-20.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation
import Moya

class MusicRoomProvider: MoyaProvider<MusicRoomService> {
    override init(endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider<Target>.defaultEndpointMapping,
                  requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider<Target>.defaultRequestMapping,
                  stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider<Target>.neverStub,
                  callbackQueue: DispatchQueue? = nil,
                  manager: Manager = MoyaProvider<Target>.defaultAlamofireManager(),
                  plugins: [PluginType] = [],
                  trackInflights: Bool = false) {

        let implPlugins = plugins + [AccessTokenPlugin(tokenClosure: {
            return MusicRoomManager.sharedInstance.token
        })]
        super.init(endpointClosure: endpointClosure,
                   requestClosure: requestClosure,
                   stubClosure: stubClosure,
                   callbackQueue: callbackQueue,
                   manager: manager,
                   plugins: implPlugins,
                   trackInflights: trackInflights)
    }
}

let provider = MusicRoomProvider()
