//
//  DeezerTracks.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/29/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation

class DeezerTracks : NSObject {
    private let playlist: API.PlaylistDetailed
    private var cachedTracks: [Int : DZRTrack] = [:]
    private var currentTrackIndex = 0

    init(with playlist: API.PlaylistDetailed, startIndex: Int?) {
        self.playlist = playlist
        self.currentTrackIndex = startIndex ?? 0
    }
}

extension DeezerTracks : DZRPlayable {
    func identifier() -> String! {
        return "Playlist"
    }

    func iterator() -> DZRPlayableIterator! {
        return self
    }
}

extension DeezerTracks : DZRPlayableRandomAccessIterator, DZRPlayableIterator {
    private func getTrack(at index: Int, with manager: DZRRequestManager, callback: DZRTrackFetchingCallback!) {
        guard index < playlist.tracks.count else {
            callback(nil, nil)
            return
        }

        currentTrackIndex = Int(index)
        if let cachedTrack = cachedTracks[currentTrackIndex] {
            callback(cachedTrack, nil)
            return
        }

        let track = playlist.tracks[currentTrackIndex]
        DZRTrack.object(withIdentifier: String(track.data.id), requestManager: DZRRequestManager.default()) { (object, error) in
            guard let track = object as? DZRTrack else { return callback(nil, error) }
            self.cachedTracks[Int(index)] = track
            callback(track, error)
        }
    }

    func track(at index: UInt, with manager: DZRRequestManager, callback: DZRTrackFetchingCallback!) {
        // For some reason Deezer SDK pass indices starting from one
        let index = max(Int(index) - 1, 0)
        getTrack(at: index, with: manager, callback: callback)
    }

    func previous(from dzrTrack: DZRTrack!, with manager: DZRRequestManager!, callback: DZRTrackFetchingCallback!) {
        previous(with: manager, callback: callback)
    }

    func next(from dzrTrack: DZRTrack!, with manager: DZRRequestManager!, callback: DZRTrackFetchingCallback!) {
        next(with: manager, callback: callback)
    }

    func previous(with requestManager: DZRRequestManager!, callback: DZRTrackFetchingCallback!) {
        if currentTrackIndex == 0 {
            callback(nil, nil)
        } else {
            getTrack(at: currentTrackIndex - 1, with: requestManager, callback: callback)
        }
    }

    func next(with requestManager: DZRRequestManager!, callback: DZRTrackFetchingCallback!) {
        // That's how deezer calls first track while having track(at:) method
        if cachedTracks.isEmpty {
            getTrack(at: currentTrackIndex, with: requestManager, callback: callback)
            return
        }

        if currentTrackIndex + 1 == playlist.tracks.count {
            callback(nil, nil)
        } else {
            getTrack(at: currentTrackIndex + 1, with: requestManager, callback: callback)
        }
    }

    func reset(_ callback: ((Error?) -> Void)!) {
        currentTrackIndex = 0
        callback(nil)
    }

    func count(_ callback: ((UInt, Error?) -> Void)!) {
        callback(UInt(playlist.tracks.count), nil)
    }

    func currentIndex() -> Int {
        return currentTrackIndex
    }

    func current(with requestManager: DZRRequestManager!, callback: DZRTrackFetchingCallback!) {
        callback(cachedTracks[currentTrackIndex], nil)
    }
}
