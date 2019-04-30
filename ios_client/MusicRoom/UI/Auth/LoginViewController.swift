//
//  LoginViewController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 3/22/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit

extension API {

struct LoginUser: Codable {
    let id: Int32
    let username: String
    let email: String
    let first_name: String
    let last_name: String

    enum CodingKeys: String, CodingKey {
        case id = "pk"
        case username
        case email
        case first_name
        case last_name
    }
}

struct LoginResponse: Decodable {
    let token: String
    let user: LoginUser
}

}

class LoginViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwdTextField: UITextField!
    @IBOutlet var mainView: UIView!

    @IBOutlet weak var forgotPasswdButton: UIBarButtonItem!
    @IBOutlet weak var loginButton: UIBarButtonItem!
    @IBOutlet var toolbar: UIToolbar!

    override func viewDidLoad() {
        super.viewDidLoad()

        let startColor = UIColor(red: 209.0 / 255.0, green: 51.0 / 255.0, blue: 48.0 / 255.0, alpha: 255.0 / 255.0)
        let endColor = UIColor(red: 92.0 / 255.0, green: 53.0 / 255.0, blue: 198.0 / 255.0, alpha: 255.0 / 255.0)
        let gradient = GradientBackground(with: mainView.bounds, startColor: startColor, endColor: endColor)
        mainView.layer.insertSublayer(gradient, at: 0)

        nameTextField.delegate = self
        passwdTextField.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        nameTextField.becomeFirstResponder()
    }

    @IBAction func loginBarAction(_ sender: Any) {
        nameTextField.endEditing(true)
        passwdTextField.endEditing(true)

        guard let email = nameTextField.text,
            let passwd = passwdTextField.text else {
                return;
        }

        loginButton.isEnabled = false

        provider.request(.login(email: email, password: passwd)) { result in
            processMoyaResult(result: result, onSuccess: { data in
                if let loginResponse = try? JSONDecoder().decode(API.LoginResponse.self, from: data) {
                    MusicRoomManager.sharedInstance.musicRoomDidLogin(token: loginResponse.token, userId: loginResponse.user.id)
                    NavigationManager.presentMusicRoomHome(from: self)
                }
            }, onFailure: { message in
                UIViewController.present(title: "Login failed", message: message, style: .danger)
                MusicRoomManager.sharedInstance.musicRoomDidNotLogin(false)
                self.loginButton.isEnabled = true
            })
        }
    }

    @IBAction func forgotPasswordAction(_ sender: Any) {
        nameTextField.endEditing(true)
        passwdTextField.endEditing(true)

        guard let email = nameTextField.text else { return }

        forgotPasswdButton.isEnabled = false

        provider.request(.resetPassword(email: email)) { result in
            processMoyaResult(result: result, onSuccess: { data in
                if let msg = try? JSONDecoder().decode(API.DetailResponse.self, from: data) {
                    UIViewController.present(title: msg.detail)
                } else {
                    UIViewController.present(title: "Password reset e-mail has been sent")
                }
                self.forgotPasswdButton.isEnabled = true
            }, onFailure: { message in
                UIViewController.present(title: "Failed to reset password", message: message, style: .danger)
                self.forgotPasswdButton.isEnabled = true
            })
        }
    }
}

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputAccessoryView = toolbar
        return true
    }
}
