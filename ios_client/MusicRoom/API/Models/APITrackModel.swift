//
//  APITrackModel.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/17/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation

extension API {

struct DeezerAlbumData: Codable {
    let id: Int32
    let cover: String
    let title: String

    init?(jsonObject: Any?) {
        guard let object = jsonObject as? [String: Any] else { return nil }

        if let id = object["id"] as? Int32,
            let cover = object["cover"] as? String,
            let title = object["title"] as? String {
            self.id = id
            self.cover = cover
            self.title = title
        } else {
            return nil
        }
    }

    init?(trackInfo: [AnyHashable: Any]?) {
        guard let info = trackInfo else {
            return nil
        }

        if let idStr = info["id"] as? String,
            let id = Int32(idStr),
            let cover = info["album.cover"] as? String,
            let title = info["album.title"] as? String {
            self.id = id
            self.cover = cover
            self.title = title
        } else {
            return nil
        }
    }
}

struct DeezerArtistData: Codable {
    let id: Int32
    let name: String

    init?(jsonObject: Any?) {
        guard let object = jsonObject as? [String: Any] else { return nil }

        if let id = object["id"] as? Int32,
            let name = object["name"] as? String {
            self.id = id
            self.name = name
        } else {
            return nil
        }
    }

    init?(trackInfo: [AnyHashable: Any]?) {
        guard let info = trackInfo else {
            return nil
        }

        if let idStr = info["id"] as? String,
            let id = Int32(idStr),
            let name = info["artist.name"] as? String {
            self.id = id
            self.name = name
        } else {
            return nil
        }
    }
}

class DeezerTrackData: Codable {
    let id: Int32
    let title: String
    let duration: Int32
    let readable: Bool
    let album: DeezerAlbumData
    let artist: DeezerArtistData

    static func load(for track: DZRTrack, completion: @escaping (DeezerTrackData?, Error?) -> Void) {
        track.values(forKeyPaths: [
            "id",
            "title",
            "duration",
            "readable",
            "album.id",
            "album.cover",
            "album.title",
            "artist.id",
            "artist.name"], with: DZRRequestManager.default()) { (info, error) in
                completion(DeezerTrackData(trackInfo: info), error)
        }
    }

    init?(trackInfo: [AnyHashable : Any]?) {
        if let info = trackInfo {
            if let idStr = info["id"] as? String,
                let id = Int32(idStr),
                let title = info["title"] as? String,
                let duration = info["duration"] as? Int32,
                let readable = info["readable"] as? Bool,
                let album = API.DeezerAlbumData(trackInfo: info),
                let artist = API.DeezerArtistData(trackInfo: info) {
                self.id = id
                self.title = title
                self.duration = duration
                self.readable = readable
                self.album = album
                self.artist = artist
                return
            }
        }
        return nil
    }

    init?(jsonObject: Any?) {
        guard let object = jsonObject as? [String: Any] else { return nil }

        if let id = object["id"] as? Int32,
            let title = object["title"] as? String,
            let duration = object["duration"] as? Int32,
            let readable = object["readable"] as? Bool,
            let album = API.DeezerAlbumData(jsonObject: object["album"]),
            let artist = API.DeezerArtistData(jsonObject: object["artist"]) {
            self.id = id
            self.title = title
            self.duration = duration
            self.readable = readable
            self.album = album
            self.artist = artist
        } else {
            return nil
        }
    }
}

struct Track : Codable {
    let playlistId: Int32
    let data: DeezerTrackData

    init(id: Int32, data: DeezerTrackData) {
        self.playlistId = id
        self.data = data
    }

    init?(jsonObject: Any?) {
        guard let object = jsonObject as? [String: Any] else { return nil }

        if let playlistId = object["playlistId"] as? Int32,
            let data = API.DeezerTrackData(jsonObject: object["data"]) {
            self.playlistId = playlistId
            self.data = data
        } else {
            return nil
        }
    }
}

}
