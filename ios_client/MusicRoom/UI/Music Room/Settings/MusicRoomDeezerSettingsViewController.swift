//
//  MusicRoomDeezerSettingsViewController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/16/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit

class MusicRoomDeezerSettingsViewController : UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var sessionChangeStatusButton: UIButton!
    private let cellId = "accountCell"

    private var infoFields: [(String, String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Deezer"

        tableView.dataSource = self
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)

        setupUI(loggedIn: DeezerManager.sharedInstance.sessionState == .connected)

        DeezerManager.sharedInstance.loginResult = {[weak self] (result) in
            switch result {
            case .success:
                self?.setupUI(loggedIn: true)
            case .logout:
                self?.setupUI(loggedIn: false)
            case let .error(error):
                print("Error occured: \(error?.code ?? 0)")
            }
        }
    }

    func setupUI(loggedIn: Bool) {
        if loggedIn {
            self.sessionChangeStatusButton.setTitle("Logout", for: .normal)

            self.infoFields = []
            DeezerManager.sharedInstance.getMe { (user, error) in
                guard let user = user else {
                    if let error = error {
                        UIViewController.present(title: "Failed to get deezer account info", error: error)
                    } else {
                        UIViewController.present(title: "Failed to get deezer account info", message: nil, style: .danger)
                    }
                    return
                }

                user.values(forKeyPaths: [
                    "name",
                    "firstname",
                    "lastname",
                    "email"], with: DZRRequestManager.default(), callback: { (info, error) in
                        guard let info = info else {
                            if let error = error {
                                UIViewController.present(title: "Failed to get deezer account info", error: error)
                            } else {
                                UIViewController.present(title: "Failed to get deezer account info", message: nil, style: .danger)
                            }
                            return
                        }

                        if let email = info["email"] as? String { self.infoFields.append(("Email", email)) }
                        if let username = info["name"] as? String { self.infoFields.append(("Username", username)) }
                        if let firstName = info["firstname"] as? String { self.infoFields.append(("First name", firstName)) }
                        if let lastName = info["lastname"] as? String { self.infoFields.append(("Last name", lastName)) }

                        if !self.infoFields.isEmpty {
                            self.tableView.reloadData()
                        }
                })
            }
        } else {
            self.sessionChangeStatusButton.setTitle("Login", for: .normal)
            self.infoFields = []
            self.tableView.reloadData()
        }
    }
    
    @IBAction func sessionChangeStatusAction(_ sender: Any) {
        if DeezerManager.sharedInstance.sessionState == .connected {
            DeezerManager.sharedInstance.logout()
        } else {
            DeezerManager.sharedInstance.login()
        }
    }
}

extension MusicRoomDeezerSettingsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoFields.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if let cell = cell as? AccountCell {
            let infoField = infoFields[indexPath.row]
            cell.propertyLabel.text = infoField.0
            cell.valueLabel.text = infoField.1
        }
        return cell
    }


}
