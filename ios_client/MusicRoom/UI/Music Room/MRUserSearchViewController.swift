//
//  MRUserListViewController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/23/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit

class MusicRoomUserSearchViewController : UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let cellId = "keyValueCell"

    private var searchBar : UISearchBar?
    private var users: [API.User]?
    private var showedUsers: [API.User]?

    var onUserSelection: ((API.User) -> Void)?
    var skippedUserIds: [Int32]?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        self.searchBar?.delegate = self
        self.searchBar?.placeholder = "Search User"

        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = self.searchBar

        search("")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar?.endEditing(false)
        definesPresentationContext = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        definesPresentationContext = false
    }

    private func loadUsers(with query: String, completion: @escaping () -> Void) {
        provider.request(.findUsers(query: query)) { result in
            switch result {
            case let .success(response):
                if let users = try? JSONDecoder().decode([API.User].self, from: response.data) {
                    self.users = users
                    completion()
                    return
                }
                var message: String?
                if let msg = try? JSONDecoder().decode(API.DetailResponse.self, from: response.data) {
                    message = msg.detail
                }
                UIViewController.present(title: "User search failed", message: message, style: .danger)
            case let .failure(error):
                UIViewController.present(title: "User search failed", error: error)
            }
        }
    }

    private func search(_ query: String) {
        loadUsers(with: query) {
            guard let users = self.users else { return }

            if query == "" {
                if let skippedUserIds = self.skippedUserIds {
                    self.showedUsers = users.filter({ user in
                      return !skippedUserIds.contains(user.id)
                    })
                } else {
                    self.showedUsers = users
                }
            } else {
                self.showedUsers = users.filter({ user in
                    if !"\(user.username) \(user.first_name) \(user.last_name)".localizedCaseInsensitiveContains(query) {
                        return false
                    } else if let skippedUserIds = self.skippedUserIds {
                        return !skippedUserIds.contains(user.id)
                    }
                    return true
                })
            }

            self.tableView.reloadData()
        }
    }

    private func clearData() {
        self.users = nil
        self.showedUsers = nil
        tableView.reloadData()
    }
}

extension MusicRoomUserSearchViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = self.showedUsers?[indexPath.row] else {
            return
        }

        if let onUserSelection = onUserSelection {
            onUserSelection(user)
            self.navigationController?.popViewController(animated: true)
        } else {
            NavigationManager.showUserAccount(from: self, userId: user.id)
        }
    }
}

extension MusicRoomUserSearchViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showedUsers?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if let cell = cell as? KeyValueCell,
            let userInfo = self.showedUsers?[indexPath.row] {
            cell.keyLabel.text = userInfo.username
            cell.valueLabel.text = "\(userInfo.first_name) \(userInfo.last_name)"
        }
        return cell
    }
}

extension MusicRoomUserSearchViewController : UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(searchText)
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = false
        return true
    }
}
