//
//  MusicRoomPlaylistSettingsViewController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/20/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation
import CoreLocation

class MusicRoomPlaylistSettingsViewController : UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let cellId = "playlistSettingsCell"

    private let datePicker = UIDatePicker()
    @IBOutlet private weak var dateTextField: UITextField!

    private var settingsSections: [(String, String, (() -> Void)?)] = []

    var playlist: API.Playlist?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: cellId, bundle: Bundle.main), forCellReuseIdentifier: cellId)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()

        datePicker.datePickerMode = .dateAndTime

        let toolbar = UIToolbar();
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.datePickerDoneAction))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.datePickerCancelAction))
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)

        self.dateTextField.inputAccessoryView = toolbar
        self.dateTextField.inputView = datePicker

        if let playlist = playlist {
            let userId = MusicRoomManager.sharedInstance.userId
            let playlistModifiable = playlist.creator == userId || playlist.owners.contains(userId)
            if playlistModifiable {
                if let detailedPlaylist = playlist as? API.PlaylistDetailed {
                    settingsSections.append(("Edit", "edit-icon", {
                        NavigationManager.showPlaylistEdit(from: self, for: detailedPlaylist)
                    }))
                }
                settingsSections.append(("Add track", "track-icon", {
                    NavigationManager.showDeezerSearch(from: self, type: .track, onSelection: { object in
                        guard let track = object as? DZRTrack else { return false }

                        API.Playlist.addTrack(toPlaylist: playlist.id, trackObject: track)
                        return true
                    })
                }))
                settingsSections.append(("Make \(playlist.is_public ? "private" : "public")",
                    playlist.is_public ? "lock-icon" : "unlock-icon",
                    {
                        provider.request(.setPlaylistPublic(id: playlist.id, isPublic: !playlist.is_public), completion: { result in
                        switch result {
                        case let .success(response):
                            if response.statusCode >= 300 {
                                var message: String?
                                if let msg = try? JSONDecoder().decode(API.DetailResponse.self, from: response.data) {
                                    message = msg.detail
                                }
                                UIViewController.present(title: "Failed to make playlist \(playlist.is_public ? "private" : "public")", message: message, style: .danger)
                                if let str = String(data: response.data, encoding: .utf8) {
                                    print(str)
                                }
                            }
                        case let .failure(error):
                            UIViewController.present(title: "Failed to make playlist \(playlist.is_public ? "private" : "public")", error: error)
                        }
                    })
                }))
                settingsSections.append(("Location", "location-icon", {
                    NavigationManager.showSelectLocationViewController(from: self, currentPlace: playlist.place,
                                                                       completion: { newPlace in
                        provider.request(.setPlaylistPlace(id: playlist.id, place: newPlace), completion: { result in
                            processMoyaResult(result: result, onSuccess: { data in
                                UIViewController.present(title: "Successfully set new location")
                            }, onFailure: { message in
                                UIViewController.present(title: "Failed to set location", message: message, style: .danger)
                            })
                        })
                    })
                }))
                settingsSections.append(("Expiration date", "date-icon", {
                    if let expirationDate = playlist.time_to?.iso8601 {
                        self.datePicker.setDate(expirationDate, animated: false)
                    } else {
                        self.datePicker.setDate(Date(timeIntervalSinceNow: 0.0), animated: false)
                    }
                    self.dateTextField.becomeFirstResponder();
                }))
            } else {
                let playlistFollowed = playlist.participants.contains(userId)
                let title = playlistFollowed ? "Stop following" : "Follow"
                settingsSections.append((title, playlistFollowed ? "unfollow-icon" : "follow-icon", {
                    provider.request(playlistFollowed ?
                        .unfollowPlaylist(id: playlist.id) :
                        .addPlaylistParticipant(id: playlist.id, userId: MusicRoomManager.sharedInstance.userId), completion: { result in
                        switch result {
                        case let .success(response):
                            if response.statusCode >= 300 {
                                var message: String?
                                if let msg = try? JSONDecoder().decode(API.DetailResponse.self, from: response.data) {
                                    message = msg.detail
                                }
                                UIViewController.present(title: "\"\(title)\" failed", message: message, style: .danger)
                                if let str = String(data: response.data, encoding: .utf8) {
                                    print(str)
                                }
                            }
                        case let .failure(error):
                            UIViewController.present(title: "\"\(title)\" failed", error: error)
                        }
                    })
                }))
            }
            settingsSections.append(("Owners", "owners-icon", {
                var onUserAdd: ((Int32) -> Void)? = nil
                var onUserRemove: ((Int32) -> Void)? = nil
                if playlistModifiable {
                    onUserAdd = { userId in
                        provider.request(.addPlaylistOwner(id: playlist.id, userId: userId), completion: { result in
                            processMoyaResult(result: result, onSuccess: { data in
                                UIViewController.present(title: "Successfully added user to owners")
                            }, onFailure: { message in
                                UIViewController.present(title: "Failed to add user to owners", message: message, style: .danger)
                            })
                        })
                    }
                    if playlist.creator == userId {
                        onUserRemove = { userId in
                            provider.request(.deletePlaylistOwner(id: playlist.id, userId: userId), completion: { result in
                                processMoyaResult(result: result, onSuccess: { data in
                                    UIViewController.present(title: "Successfully deleted user from owners")
                                }, onFailure: { message in
                                    UIViewController.present(title: "Failed to delete user from owners", message: message, style: .danger)
                                })
                            })
                        }
                    }
                }
                NavigationManager.showUserList(from: self, userIds: playlist.owners,
                                               onUserAdd: onUserAdd, onUserRemove: onUserRemove)
            }))
            settingsSections.append(("Participants", "participants-icon", {
                var onUserAdd: ((Int32) -> Void)? = nil
                if playlistModifiable || playlist.participants.contains(userId) {
                    onUserAdd = { userId in
                        provider.request(.addPlaylistParticipant(id: playlist.id, userId: userId), completion: { result in
                            processMoyaResult(result: result, onSuccess: { data in
                                UIViewController.present(title: "Successfully added user to participants")
                            }, onFailure: { message in
                                UIViewController.present(title: "Failed to add user to participants", message: message, style: .danger)
                            })
                        })
                    }
                }
                var onUserRemove: ((Int32) -> Void)? = nil
                if playlistModifiable {
                    onUserRemove = { userId in
                        provider.request(.deletePlaylistParticipant(id: playlist.id, userId: userId), completion: { result in
                            processMoyaResult(result: result, onSuccess: { data in
                                UIViewController.present(title: "Successfully deleted user from participants")
                            }, onFailure: { message in
                                UIViewController.present(title: "Failed to delete user from participants", message: message, style: .danger)
                            })
                        })
                    }
                }
                NavigationManager.showUserList(from: self, userIds: playlist.participants,
                                               onUserAdd: onUserAdd, onUserRemove: onUserRemove)
            }))
            if playlist.creator == userId {
                settingsSections.append(("Delete", "delete-icon", {
                    self.askForConfirmation(actionTitle: "Delete playlist", onConfirm: {
                        provider.request(.deletePlaylist(id: playlist.id), completion: { result in
                            switch result {
                            case let .success(response):
                                if response.statusCode >= 300 {
                                    var message: String?
                                    if let msg = try? JSONDecoder().decode(API.DetailResponse.self, from: response.data) {
                                        message = msg.detail
                                    }
                                    UIViewController.present(title: "Failed to delete playlist", message: message, style: .danger)
                                    if let str = String(data: response.data, encoding: .utf8) {
                                        print(str)
                                    }
                                } else {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            case let .failure(error):
                                UIViewController.present(title: "Failed to delete playlist", error: error)
                            }
                        })
                    }, onCancel: nil)
                }))
            }
        }
    }
}

extension MusicRoomPlaylistSettingsViewController {
    @objc private func datePickerDoneAction() {
        self.view.endEditing(true)
        if let playlist = playlist {
            provider.request(.setPlaylistExpirationDate(id: playlist.id, date: self.datePicker.date), completion: { result in
                processMoyaResult(result: result, onSuccess: { _ in
                    let formatter = DateFormatter()
                    formatter.dateStyle = .short
                    formatter.timeStyle = .short
                    UIViewController.present(title: "Successfully set new exporation date", message: formatter.string(from: self.datePicker.date), style: .success)
                }, onFailure: { message in
                    UIViewController.present(title: "Failed to set playlist exporation date", message: message, style: .danger)
                })
            })
        }
    }

    @objc private func datePickerCancelAction() {
        self.view.endEditing(true)
    }
}

extension MusicRoomPlaylistSettingsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsSections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if let cell = cell as? PlaylistSettingsCell {
            let section = settingsSections[indexPath.row]
            cell.label.text = section.0
            cell.iconImage.image = UIImage(named: section.1)?.withAlignmentRectInsets(UIEdgeInsets(top: -12.5, left: -12.5, bottom: -12.5, right: -12.5))
        }
        return cell
    }
}

extension MusicRoomPlaylistSettingsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        settingsSections[indexPath.row].2?()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
