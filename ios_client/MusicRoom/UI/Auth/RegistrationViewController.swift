//
//  RegistrationViewController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 3/22/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit

extension API {
    struct DetailResponse: Decodable {
        let detail: String
    }
}

class RegistrationViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwdTextField: UITextField!
    @IBOutlet weak var passwdConfirmationTextField: UITextField!
    @IBOutlet var mainView: UIView!

    @IBOutlet weak var registerButton: UIBarButtonItem!
    @IBOutlet var toolbar: UIToolbar!

    override func viewDidLoad() {
        super.viewDidLoad()

        let startColor = UIColor(red: 209.0 / 255.0, green: 51.0 / 255.0, blue: 48.0 / 255.0, alpha: 255.0 / 255.0)
        let endColor = UIColor(red: 92.0 / 255.0, green: 53.0 / 255.0, blue: 198.0 / 255.0, alpha: 255.0 / 255.0)
        let gradient = GradientBackground(with: mainView.bounds, startColor: startColor, endColor: endColor)
        mainView.layer.insertSublayer(gradient, at: 0)

        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwdTextField.delegate = self
        passwdConfirmationTextField.delegate = self

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func registerAction(_ sender: Any) {
        guard let email = emailTextField.text,
            let name = usernameTextField.text,
            let passwd = passwdTextField.text,
            let passwdConfirmation = passwdConfirmationTextField.text else {
                return
        }

        registerButton.isEnabled = false

        if email == "" {
            UIViewController.present(title: "Wrong credentials", message: "Email may not be blank.", style: .danger)
            return
        }

        if name == "" {
            UIViewController.present(title: "Wrong credentials", message: "Username may not be blank.", style: .danger)
            return
        }

        if passwd == "" {
            UIViewController.present(title: "Wrong credentials", message: "Password may not be blank.", style: .danger)
            return
        }

        if passwd != passwdConfirmation {
            UIViewController.present(title: "Wrong password", message: "Password and confirm password does not match", style: .danger)
            return
        }

        provider.request(.register(username: name, password: passwd, email: email)) { result in
            processMoyaResult(result: result, onSuccess: { data in
                if let _ = try? JSONDecoder().decode(API.DetailResponse.self, from: data) {
                    self.navigationController?.popViewController(animated: true)
                    guard let loginVC = LoginViewController.makeFromStoryboard(nameStoryboard: "Auth") as? LoginViewController else {
                        return
                    }
                    self.navigationController?.pushViewController(loginVC, animated: true)
                } else {
                    let message = parseUnknownErrorResponse(data: data)
                    UIViewController.present(title: "Registration failed", message: message, style: .danger)
                    self.registerButton.isEnabled = true
                }
            }, onFailure: { message in
                UIViewController.present(title: "Registration failed", message: message, style: .danger)
                self.registerButton.isEnabled = true
            })
        }
    }
}

extension RegistrationViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputAccessoryView = toolbar
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1

        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }

        return false
    }
}
