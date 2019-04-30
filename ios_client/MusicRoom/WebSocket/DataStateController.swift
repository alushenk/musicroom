//
//  DataStateer.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/27/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation
import Starscream

protocol DataStateDelegate : NSObjectProtocol {
    func refreshData()
    func removeData()
}

class DataStateController : NSObject {
    private let url: URL
    private let websocket: WebSocket
    private weak var delegate: DataStateDelegate?

    init?(urlString: String, delegate: DataStateDelegate?) {
        guard let url = URL(string: urlString) else { return nil }

        self.url = url
        self.delegate = delegate

        websocket = WebSocket(url: url, protocols: ["chat"])

        super.init()

        websocket.onDisconnect = { error in
//            if let error = error {
//                print("\(url) - disconnected with error: \(error)")
//                UIViewController.present(title: "Lost connection to server", message: "Real-time refresh is disabled", style: .danger)
//            } else {
//                print("\(url) - disconnected")
//            }
        }

        websocket.onText = { [weak self] text in
            struct SocketResponse : Decodable {
                let message: String
            }

            guard let strongSelf = self,
                let response = try? JSONDecoder().decode(SocketResponse.self, from: text.data) else { return }

            switch response.message {
            case "delete":
                strongSelf.websocket.onText = nil
                strongSelf.websocket.disconnect()
                strongSelf.delegate?.removeData()
            case "refresh":
                strongSelf.delegate?.refreshData()
            default:
                break
            }
        }

        websocket.connect()
    }
}
