//
//  VoteController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/30/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation

class VoteController : NSObject {
    private let playlist: API.PlaylistDetailed

    init(with playlist: API.PlaylistDetailed) {
        self.playlist = playlist

        super.init()
    }

    func trackIsVoted(track: DZRTrack) -> Bool {
        guard let playlistTrack = playlist.tracks.first(where: { playlistTrack -> Bool in
            guard let id = Int(track.identifier()) else { return false }
            return playlistTrack.data.id == id
        }) else {
            return false
        }

        return playlistTrack.votes.contains { vote -> Bool in
            return vote.user_id == MusicRoomManager.sharedInstance.userId
        }
    }

    func voteTrack(track: DZRTrack, onSuccess: @escaping (Bool) -> Void) {
        guard let playlistTrack = playlist.tracks.first(where: { playlistTrack -> Bool in
            guard let id = Int(track.identifier()) else { return false }
            return playlistTrack.data.id == id
        }) else {
            UIViewController.present(title: "Failed to vote track", message: "Could not find", style: .danger)
            return
        }

        provider.request(.vote(trackId: playlistTrack.id), completion: { result in
            processMoyaResult(result: result, onSuccess: { data in
                onSuccess(!data.isEmpty)
            }, onFailure: { message in
                UIViewController.present(title: "Failed to track track", message: message, style: .danger)
            })
        })
    }
}
