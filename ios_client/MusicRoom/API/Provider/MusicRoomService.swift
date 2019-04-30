//
//  MusicRoomService.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 3/16/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation
import Moya

enum MusicRoomService {
    case register(username: String, password: String, email: String)
    case login(email: String, password: String)
    case googleLogin(token: String)
    case resetPassword(email: String)

    case getPlaylists
    case getPlaylistsOf(userId: Int32)
    case getPlaylist(id: Int32)
    case setPlaylistPlace(id: Int32, place: API.Place)
    case setPlaylistPublic(id: Int32, isPublic: Bool)
    case setPlaylistExpirationDate(id: Int32, date: Date)
    case setPlaylistName(id: Int32, name: String)
    case deletePlaylist(id: Int32)
    case createPlaylist(name: String)

    case addPlaylistTrack(id: Int32, trackData: API.DeezerTrackData)
    case deleteTrack(trackId: Int32)

    case addPlaylistParticipant(id: Int32, userId: Int32)
    case deletePlaylistParticipant(id: Int32, userId: Int32)
    case unfollowPlaylist(id: Int32)

    case addPlaylistOwner(id: Int32, userId: Int32)
    case deletePlaylistOwner(id: Int32, userId: Int32)

    case vote(trackId: Int32)

    case findUsers(query: String)
    case getUser(id: Int32)
    case updateUser(firstName: String?, lastName: String?)
    case changePassword(password: String)
}

extension MusicRoomService: AccessTokenAuthorizable {
    var authorizationType: AuthorizationType {
        switch self {
        case .register, .login, .googleLogin, .resetPassword:
            return .none
        default:
            return .custom("JWT")
        }
    }
}

extension MusicRoomService: TargetType {
    var baseURL: URL {
        return URL(string: "https://musicroom.ml")!
    }

    var path: String {
        switch self {
        case .register:
            return "/auth/registration/"
        case .login:
            return "/auth/login/"
        case .googleLogin:
            return "/auth/google/"
        case .resetPassword:
            return "/auth/password/reset/"
        case .getPlaylists, .createPlaylist:
            return "/api/playlists/"
        case .getPlaylistsOf(let id):
            return "/api/users/\(id)/playlists/"
        case .getPlaylist(let id), .deletePlaylist(let id),
             .setPlaylistPlace(let id, _),
             .setPlaylistPublic(let id, _),
             .setPlaylistExpirationDate(let id, _),
             .setPlaylistName(let id, _):
            return "/api/playlists/\(id)/"
        case .addPlaylistParticipant(let id, let userId), .deletePlaylistParticipant(let id, let userId):
            return "/api/playlists/\(id)/participants/\(userId)/"
        case .addPlaylistOwner(let id, let userId), .deletePlaylistOwner(let id, let userId):
            return "/api/playlists/\(id)/owners/\(userId)/"
        case .unfollowPlaylist(let id):
            return "/api/playlists/\(id)/users/\(MusicRoomManager.sharedInstance.userId)/"
        case .addPlaylistTrack:
            return "/api/tracks/"
        case .deleteTrack(let id):
            return "/api/tracks/\(id)/"
        case .getUser(let id):
            return "/api/users/\(id)/"
        case .updateUser:
            return "/api/users/\(MusicRoomManager.sharedInstance.userId)/"
        case .changePassword:
            return "/auth/password/change/"
        case .findUsers:
            return "/api/users/user_search/"
        case .vote(let id):
            return "/api/votes/\(id)/"
        }
    }

    var method: Moya.Method {
        switch self {
        case .register,
             .login,
             .googleLogin,
             .resetPassword,
             .changePassword,
             .createPlaylist,
             .addPlaylistTrack,
             .vote:
            return .post
        case .getPlaylists,
             .getPlaylistsOf,
             .getPlaylist,
             .getUser,
             .findUsers:
            return .get
        case .setPlaylistPlace,
             .setPlaylistPublic,
             .setPlaylistName,
             .setPlaylistExpirationDate,
             .updateUser,
             .addPlaylistParticipant,
             .addPlaylistOwner:
            return .patch
        case .deletePlaylist,
             .deletePlaylistParticipant,
             .deletePlaylistOwner,
             .deleteTrack,
             .unfollowPlaylist:
            return .delete
        }
    }

    var sampleData: Data {
        switch self {
        default:
            return "Implement me".data(using: .utf8)!
        }
    }

    var task: Task {
        switch self {
        case .register(let username, let password, let email):
            return .requestParameters(parameters: [
                "username": username,
                "password1": password,
                "password2": password,
                "email": email], encoding: JSONEncoding.default)
        case .login(let email, let password):
            return .requestParameters(parameters: [
                "email": email,
                "password": password], encoding: JSONEncoding.default)
        case .googleLogin(let token):
            return .requestParameters(parameters: ["access_token": token], encoding: JSONEncoding.default)
        case .resetPassword(let email):
            return .requestParameters(parameters: ["email": email], encoding: JSONEncoding.default)
        case .updateUser(let firstName, let lastName):
            var parameters: [String: Any] = [:]
            if let name = firstName {
                parameters["first_name"] = name
            }
            if let name = lastName {
                parameters["last_name"] = name
            }
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .changePassword(let password):
            return .requestParameters(parameters: [
                "new_password1": password,
                "new_password2": password], encoding: JSONEncoding.default)
        case .setPlaylistPlace(_, let place):
            struct PlacePatch : Encodable {
                let place: API.Place
            }
            return .requestJSONEncodable(PlacePatch(place: place))
        case .setPlaylistPublic(_, let isPublic):
            return .requestParameters(parameters: ["is_public": isPublic], encoding: JSONEncoding.default)
        case .setPlaylistExpirationDate(_, let date):
            return .requestParameters(parameters: ["time_to": date.iso8601], encoding: JSONEncoding.default)
        case .setPlaylistName(_, let name):
            return .requestParameters(parameters: ["name": name], encoding: JSONEncoding.default)
        case .createPlaylist(let name):
            return .requestJSONEncodable(API.PlaylistCreationModel(name: name))
        case .addPlaylistTrack(let playlistId, let data):
            struct PlaylistAddModel : Encodable {
                let playlist: Int32
                let data: API.DeezerTrackData
            }
            return .requestJSONEncodable(PlaylistAddModel(playlist: playlistId, data: data))
        case .findUsers(let query):
            return .requestParameters(parameters: ["name": query], encoding: URLEncoding.default)
        case .vote,
             .getUser,
             .getPlaylist,
             .getPlaylists,
             .getPlaylistsOf,
             .addPlaylistOwner,
             .addPlaylistParticipant,
             .unfollowPlaylist,
             .deletePlaylist,
             .deleteTrack,
             .deletePlaylistOwner,
             .deletePlaylistParticipant:
            return .requestPlain
        }
    }

    var headers: [String : String]? {
        return ["Content-type": "application/json",
                "Referer": "https://musicroom.ml/swagger"]
    }
}
