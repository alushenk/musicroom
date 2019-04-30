//
//  NavigationManager+MusicRoom.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/15/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation
import CoreLocation

extension NavigationManager {
    static func showMusicRoomPlaylistsList(from viewController: UIViewController, query: String?, onSelection: ((API.Playlist) -> Bool)?) {
        guard let playlistsListViewController = MusicRoomPlaylistListViewController.makeFromStoryboard(nameStoryboard: "MusicRoom") as? MusicRoomPlaylistListViewController else {
            return
        }
        playlistsListViewController.query = query
        playlistsListViewController.onSelection = onSelection
        viewController.navigationController?.pushViewController(playlistsListViewController, animated: true)
    }

    static func showMusicRoomPlaylist(from viewController: UIViewController, playlist: API.Playlist) {
        guard let playlistViewController = MusicRoomPlaylistViewController.makeFromStoryboard(nameStoryboard: "MusicRoom") as? MusicRoomPlaylistViewController else {
            return
        }
        playlistViewController.shortPlaylist = playlist
        viewController.navigationController?.pushViewController(playlistViewController, animated: true)
    }

    static func showMusicRoomPlaylistSettings(from viewController: UIViewController, playlist: API.Playlist) {
        guard let settingsViewController = MusicRoomPlaylistSettingsViewController.makeFromStoryboard(nameStoryboard: "MusicRoom") as? MusicRoomPlaylistSettingsViewController else {
            return
        }
        settingsViewController.playlist = playlist
        viewController.navigationController?.pushViewController(settingsViewController, animated: true)
    }

    static func showUserList(from viewController: UIViewController, userIds: [Int32], onUserAdd: ((Int32) -> Void)? = nil, onUserRemove: ((Int32) -> Void)? = nil) {
        guard let userListVC = MusicRoomUserListViewController.makeFromStoryboard(nameStoryboard: "MusicRoom") as? MusicRoomUserListViewController else {
            return
        }
        userListVC.userIds = userIds
        userListVC.addUserCallback = onUserAdd
        userListVC.removeUserCallback = onUserRemove
        viewController.navigationController?.pushViewController(userListVC, animated: true)
    }

    static func findUser(from viewController: UIViewController, skippedUserIds: [Int32]? = nil, onUserSelection: ((API.User) -> Void)? = nil) {
        guard let findUserVC = MusicRoomUserSearchViewController.makeFromStoryboard(nameStoryboard: "MusicRoom") as? MusicRoomUserSearchViewController else {
            return
        }
        findUserVC.onUserSelection = onUserSelection
        findUserVC.skippedUserIds = skippedUserIds
        viewController.navigationController?.pushViewController(findUserVC, animated: true)
    }

    static func showPlaylistEdit(from viewController: UIViewController, for playlist: API.PlaylistDetailed) {
        guard let editPlaylistVC = MRPlaylistEditViewController.makeFromStoryboard(nameStoryboard: "MusicRoom") as? MRPlaylistEditViewController else {
            return
        }
        editPlaylistVC.playlist = playlist
        viewController.navigationController?.pushViewController(editPlaylistVC, animated: true)
    }
}
