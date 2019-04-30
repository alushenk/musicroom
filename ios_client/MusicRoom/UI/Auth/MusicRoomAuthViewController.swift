//
//  MusicRoomAuthViewController.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/14/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit
import Simplicity

class MusicRoomAuthViewController : UIViewController {
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet var mainView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        googleButton.layer.cornerRadius = googleButton.bounds.height / 2
        loginButton.layer.cornerRadius = loginButton.bounds.height / 2
        registerButton.layer.cornerRadius = registerButton.bounds.height / 2

        let startColor = UIColor(red: 209.0 / 255.0, green: 51.0 / 255.0, blue: 48.0 / 255.0, alpha: 255.0 / 255.0)
        let endColor = UIColor(red: 92.0 / 255.0, green: 53.0 / 255.0, blue: 198.0 / 255.0, alpha: 255.0 / 255.0)
        let gradient = GradientBackground(with: mainView.bounds, startColor: startColor, endColor: endColor)
        mainView.layer.insertSublayer(gradient, at: 0)

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }

    @IBAction func googleLoginAction(_ sender: Any) {
        Simplicity.login(Google()) { (accessToken, error) in
            if let token = accessToken {
                provider.request(.googleLogin(token: token), completion: { result in
                    switch result {
                    case let .success(response):
                        if response.statusCode <= 201 {
                            if let loginResponse = try? JSONDecoder().decode(API.LoginResponse.self, from: response.data) {
                                MusicRoomManager.sharedInstance.musicRoomDidLogin(token: loginResponse.token, userId: loginResponse.user.id)
                                NavigationManager.presentMusicRoomHome(from: self)
                                return
                            }
                        }
                        UIViewController.present(title: "Google authentication failed", message: nil)
                        print("Google login status code: \(response.statusCode)")
                        if let body = String(data: response.data, encoding: .utf8) {
                            print("Response body:\n\(body)")
                        }
                    case let .failure(error):
                        UIViewController.present(title: "Google authentication failed", error: error)
                    }
                })
            } else if let error = error {
                UIViewController.present(title: "Google authentication failed", error: error)
            }
        }
    }
}
