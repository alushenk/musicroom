//
//  MRSelectUserViewController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/23/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit

class MusicRoomUserListViewController : UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let removeCellId = "editPlaylistCell"
    private let defaultCellId = "keyValueCell"

    private var doneEditButton: UIBarButtonItem?
    private var editUsersButton: UIBarButtonItem?
    private var addUserButton: UIBarButtonItem?

    var addUserCallback: ((Int32) -> Void)?
    var removeUserCallback: ((Int32) -> Void)?

    var userIds: [Int32]?
    private var userInfos: [Int32 : API.User] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: removeCellId, bundle: nil), forCellReuseIdentifier: removeCellId)
        tableView.register(UINib(nibName: defaultCellId, bundle: nil), forCellReuseIdentifier: defaultCellId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()

        if let userIds = userIds {
            for userId in userIds {
                provider.request(.getUser(id: userId)) { result in
                    switch result {
                    case let .success(response):
                        if response.statusCode < 300 {
                            if let userInfo = try? JSONDecoder().decode(API.User.self, from: response.data) {
                                self.userInfos[userId] = userInfo
                                if self.userInfos.count == userIds.count {
                                    self.tableView.reloadData()
                                }
                                return
                            }
                        } else {
                            var message: String?
                            if let msg = try? JSONDecoder().decode(API.DetailResponse.self, from: response.data) {
                                message = msg.detail
                            }
                            UIViewController.present(title: "Failed to get user info", message: message, style: .danger)
                        }
                    case let .failure(error):
                        UIViewController.present(title: "Failed to get user info", error: error)
                    }
                }
            }

            if addUserCallback == nil && removeUserCallback == nil {
                return
            }

            if removeUserCallback != nil {
                doneEditButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.editUsersAction(_:)))
                doneEditButton?.isEnabled = true
                doneEditButton?.tintColor = self.view.tintColor

                editUsersButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.editUsersAction(_:)))
                editUsersButton?.isEnabled = true
                editUsersButton?.tintColor = self.view.tintColor
                self.navigationItem.rightBarButtonItem = editUsersButton

                if addUserCallback != nil {
                    addUserButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addUserAction(_:)))
                    addUserButton?.isEnabled = false
                    addUserButton?.tintColor = .clear
                }

                self.navigationItem.leftItemsSupplementBackButton = false
            } else {
                addUserButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addUserAction(_:)))
                addUserButton?.isEnabled = true
                addUserButton?.tintColor = self.view.tintColor
                self.navigationItem.rightBarButtonItem = addUserButton
            }
        }
    }

    private func inDefaultMode() -> Bool {
        return self.navigationItem.rightBarButtonItem == editUsersButton
    }

    @objc private func editUsersAction(_ sender: Any) {
        if inDefaultMode() {
            self.navigationItem.rightBarButtonItem = doneEditButton
            tableView.allowsSelection = false

            self.navigationItem.leftBarButtonItem = addUserButton
            addUserButton?.isEnabled = true
            UIView.animate(withDuration: 0.5, animations: {
                self.addUserButton?.tintColor = self.view.tintColor
            })
        } else {
            self.navigationItem.rightBarButtonItem = editUsersButton
            tableView.allowsSelection = true

            UIView.animate(withDuration: 0.5, animations: {
                self.addUserButton?.tintColor = UIColor.clear
            }) { success in
                self.addUserButton?.isEnabled = false
                self.navigationItem.leftBarButtonItem = nil
            }
        }

        tableView.reloadSections(IndexSet(integersIn: 0...0), with: .fade)
    }

    @objc private func addUserAction(_ sender: Any) {
        guard let addUserCallback = self.addUserCallback else {
            return
        }

        NavigationManager.findUser(from: self, skippedUserIds: userIds) { user in
            addUserCallback(user.id)
        }
    }
}

extension MusicRoomUserListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.isHidden = userInfos.count == 0
        return userInfos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userInfoPair = userInfos[userInfos.index(userInfos.startIndex, offsetBy: indexPath.row)]
        let userInfo = userInfoPair.value

        if inDefaultMode() {
            let cell = tableView.dequeueReusableCell(withIdentifier: defaultCellId, for: indexPath)
            if let cell = cell as? KeyValueCell {
                cell.keyLabel.text = userInfo.username
                cell.valueLabel.text = "\(userInfo.first_name) \(userInfo.last_name)"
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: removeCellId, for: indexPath)
            if let cell = cell as? EditPlaylistCell {
                cell.playlistName.text = userInfo.username
                cell.deleteAction = {
                    self.askForConfirmation(actionTitle: "Remove user", onConfirm: {
                        self.removeUserCallback?(userInfoPair.key)
                    }, onCancel: nil)
                }
            }
            return cell
        }
    }
}

extension MusicRoomUserListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let userId = userInfos[userInfos.index(userInfos.startIndex, offsetBy: indexPath.row)].key
        NavigationManager.showUserAccount(from: self, userId: userId)
    }
}
