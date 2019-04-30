//
//  MusicRoomAccountViewController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/16/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit

class MusicRoomAccountViewController : UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var changePasswordButton: UITableView!
    private let cellId = "accountCell"

    @IBOutlet private weak var failedToLoadLabel: UILabel!

    typealias InfoFieldUpdater = () -> Void
    private var userInfoFields: [(String, String, InfoFieldUpdater?)] = []

    var userId: Int32?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: cellId, bundle: Bundle.main), forCellReuseIdentifier: cellId)
        tableView.dataSource = self
        tableView.delegate = self

        let showingMyInfo = userId == nil || userId == MusicRoomManager.sharedInstance.userId
        tableView.allowsSelection = showingMyInfo
        if !showingMyInfo {
            tableView.tableFooterView = UIView()
        }

        setupUserInfoFields()
    }

    func setupUserInfoFields() {
        userInfoFields = []
        provider.request(.getUser(id: userId ?? MusicRoomManager.sharedInstance.userId)) { result in
            switch result {
            case let .success(response):
                if response.statusCode < 300 {
                    if let user = try? JSONDecoder().decode(API.User.self, from: response.data) {
                        self.userInfoFields.append(("Username", user.username, nil))
                        self.userInfoFields.append(("Email", user.email, nil))

                        let presentChangeController: (String, @escaping (String) -> Void) -> Void = { prefix, action in
                            let alertController = UIAlertController(title: "Change \(prefix)", message: nil, preferredStyle: .alert)

                            alertController.addTextField(configurationHandler: nil)

                            let changeAction = UIAlertAction(title: "Change", style: .default) { _ in
                                if let text = alertController.textFields?[0].text {
                                    action(text)
                                }
                            }
                            alertController.addAction(changeAction)

                            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                            alertController.addAction(cancelAction)

                            self.present(alertController, animated: true, completion: nil)
                        }

                        self.userInfoFields.append(("First Name", user.first_name, {
                            presentChangeController("First Name", { text in
                                provider.request(.updateUser(firstName: text, lastName: nil), completion: { result in
                                    switch result {
                                    case let .success(response):
                                        if response.statusCode < 300 {
                                            UIViewController.present(title: "Successfully changed name")
                                            self.setupUserInfoFields()
                                        } else {
                                            var message: String?
                                            if let msg = try? JSONDecoder().decode(API.DetailResponse.self, from: response.data) {
                                                message = msg.detail
                                            }
                                            UIViewController.present(title: "Failed to change First Name", message: message, style: .danger)
                                        }
                                    case let .failure(error):
                                        UIViewController.present(title: "Failed to change First Name", error: error)
                                    }
                                })
                            })
                        }))
                        self.userInfoFields.append(("Last Name", user.last_name,  {
                            presentChangeController("Last Name", { text in
                                provider.request(.updateUser(firstName: nil, lastName: text), completion: { result in
                                    switch result {
                                    case let .success(response):
                                        if response.statusCode < 300 {
                                            self.setupUserInfoFields()
                                        } else {
                                            var message: String?
                                            if let msg = try? JSONDecoder().decode(API.DetailResponse.self, from: response.data) {
                                                message = msg.detail
                                            }
                                            UIViewController.present(title: "Failed to change Last Name", message: message, style: .danger)
                                        }
                                    case let .failure(error):
                                        UIViewController.present(title: "Failed to change Last Name", error: error)
                                    }
                                })
                            })
                        }))

                        self.tableView.reloadData()
                        return
                    }
                }
            case .failure:
                break
            }
            self.setupInvalidState()
        }
    }

    func setupInvalidState() {
        userInfoFields = []
        tableView.isHidden = true
    }

    @IBAction func changePasswordAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Change password", message: nil, preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.textContentType = .newPassword
            textField.placeholder = "New Password"
        }
        alertController.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.textContentType = .newPassword
            textField.placeholder = "Confirm Password"
        }

        let changeAction = UIAlertAction(title: "Change", style: .default) { _ in
            if alertController.textFields?.count == 2,
                let passwd = alertController.textFields?[0].text,
                let passwdConfirmation = alertController.textFields?[1].text {
                if passwd != passwdConfirmation {
                    UIViewController.present(title: "Failed to change password", message: "Password and confirm password does not match", style: .danger)
                } else if passwd == "" {
                    UIViewController.present(title: "Failed to change password", message: "Password must not be empty", style: .danger)
                } else {
                    provider.request(.changePassword(password: passwd), completion: { result in
                        processMoyaResult(result: result, onSuccess: { _ in
                            UIViewController.present(title: "Successfully changed password")
                        }, onFailure: { message in
                            UIViewController.present(title: "Failed to change password", message: message, style: .danger)
                        })
                    })
                }
            }
        }
        alertController.addAction(changeAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
}

extension MusicRoomAccountViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let infoFieldUpdater = userInfoFields[indexPath.row].2 {
            infoFieldUpdater()
        }
    }
}

extension MusicRoomAccountViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.tableFooterView?.isHidden = userInfoFields.count == 0
        return userInfoFields.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if let cell = cell as? AccountCell {
            let infoField = userInfoFields[indexPath.row]
            cell.propertyLabel.text = infoField.0
            cell.valueLabel.text = infoField.1
        }
        return cell
    }
}
