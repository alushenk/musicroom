//
//  PlaylistModel.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/13/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation

extension API {

struct PlaylistCreationModel: Encodable {
    let name: String
    let is_public = true
    let is_active = true
    let time_from: String? = nil
    let time_to: String? = nil
}

struct Place: Codable {
    let lon: Double
    let lat: Double
    let radius: Double

    init(lon: Double, lat: Double, radius: Double) {
        self.lon = lon
        self.lat = lat
        self.radius = radius
    }

    init?(from jsonObject: Any?) {
        guard let object = jsonObject as? [String: Any] else { return nil }

        if let lon = object["lon"] as? Double,
            let lat = object["lat"] as? Double,
            let radius = object["radius"] as? Double {
            self.lon = lon
            self.lat = lat
            self.radius = radius
        } else {
            return nil
        }
    }
}

class Playlist: Codable {
    let id: Int32
    let is_public: Bool
    let name: String
    let place: Place?
    let time_from: String?
    let time_to: String?
    let creator: Int32
    let owners: [Int32]
    let participants: [Int32]

    init(detailedPlaylist: API.PlaylistDetailed) {
        id = detailedPlaylist.id
        is_public = detailedPlaylist.is_public
        name = detailedPlaylist.name
        place = detailedPlaylist.place
        time_from = detailedPlaylist.time_from
        time_to = detailedPlaylist.time_to
        creator = detailedPlaylist.creator
        owners = detailedPlaylist.owners
        participants = detailedPlaylist.participants
    }

    init?(jsonObject: [String: Any]?) {
        guard let object = jsonObject else { return nil }

        self.place = API.Place(from: object["place"])
        self.time_from = object["time_from"] as? String? ?? nil
        self.time_to = object["time_to"] as? String? ?? nil
        if let id = object["id"] as? Int32,
            let is_public = object["is_public"] as? Bool,
            let name = object["name"] as? String,
            let creator = object["creator"] as? Int32,
            let owners = object["owners"] as? [Int32],
            let participants = object["participants"] as? [Int32] {
            self.id = id
            self.is_public = is_public
            self.name = name
            self.creator = creator
            self.owners = owners
            self.participants = participants
        } else {
            return nil
        }
    }

    static func addTrack(toPlaylist id: Int32, trackObject: DZRTrack) {
        API.DeezerTrackData.load(for: trackObject, completion: { (trackData, error) in
            guard let trackData = trackData else {
                UIViewController.present(title: "Failed to add track", message: error?.localizedDescription, style: .danger)
                return
            }

            provider.request(.addPlaylistTrack(id: id, trackData: trackData), completion: { result in
                processMoyaResult(result: result, onSuccess: { _ in
                    UIViewController.present(title: "Successfully added track")
                }, onFailure: { message in
                    UIViewController.present(title: "Failed to add track", message: message, style: .danger)
                })
            })
        })
    }
}

struct Vote: Codable {
    let track_id: Int32
    let user_id: Int32

    init?(jsonObject: Any?) {
        guard let object = jsonObject as? [String: Any] else { return nil }

        if let track_id = object["track"] as? Int32,
            let user_id = object["user"] as? Int32 {
            self.track_id = track_id
            self.user_id = user_id
        } else {
            return nil
        }
    }
}

struct PlaylistTrack: Codable {
    let id: Int32
    let playlist: Int32
    let order: Int32
    var votes: [Vote]
    let data: DeezerTrackData

    init?(jsonObject: Any?) {
        guard let object = jsonObject as? [String: Any] else { return nil }

        if let id = object["id"] as? Int32,
            let playlist = object["playlist"] as? Int32,
            let order = object["order"] as? Int32,
            let voteObjects = object["votes"] as? [[String: Any]],
            let data = API.DeezerTrackData(jsonObject: object["data"]) {
            self.votes = {
                var votes: [Vote] = []
                for voteObject in voteObjects {
                    if let vote = API.Vote(jsonObject: voteObject) {
                        votes.append(vote)
                    }
                }
                return votes
            }()

            self.id = id
            self.playlist = playlist
            self.order = order
            self.data = data
        } else {
            return nil
        }
    }
}

struct PlaylistActions: Codable {
    let add_participant: Bool
    let retrieve: Bool
    let list: Bool
    let unfollow: Bool
    let update: Bool
    let followdestroy: Bool
    let add_owner: Bool
    let partial_update: Bool
    let follow: Bool

    init?(jsonObject: Any?) {
        guard let object = jsonObject as? [String: Any] else { return nil }

        if let add_participant = object["add_participant"] as? Bool,
            let retrieve = object["retrieve"] as? Bool,
            let list = object["list"] as? Bool,
            let unfollow = object["unfollow"] as? Bool,
            let update = object["update"] as? Bool,
            let followdestroy = object["follow"] as? Bool,
            let add_owner = object["add_owner"] as? Bool,
            let partial_update = object["partial_update"] as? Bool,
            let follow = object["follow"] as? Bool {
            self.add_participant = add_participant
            self.retrieve = retrieve
            self.list = list
            self.unfollow = unfollow
            self.update = update
            self.followdestroy = followdestroy
            self.add_owner = add_owner
            self.partial_update = partial_update
            self.follow = follow
        } else {
            return nil
        }
    }
}

class PlaylistDetailed: Playlist {
    let tracks: [PlaylistTrack]
    let actions: PlaylistActions

    override init?(jsonObject: [String: Any]?) {
        guard let object = jsonObject else { return nil }

        if let actions = API.PlaylistActions(jsonObject: object["actions"]),
            let trackObjects = object["tracks"] as? [[String: Any]] {
            self.tracks = {
                var tracks: [PlaylistTrack] = []
                for trackObject in trackObjects {
                    if let track = API.PlaylistTrack(jsonObject: trackObject) {
                        tracks.append(track)
                    }
                }
                return tracks
            }()

            self.actions = actions

            super.init(jsonObject: jsonObject)
        } else {
            return nil
        }
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

}
