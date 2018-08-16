//
//  OnboardingStepPageViewController.swift
//  MenuD
//
//  Created by Guilherme Hayashi on 08/03/2017.
//  Copyright © 2017 Macbook Pro. All rights reserved.
//

import Foundation

class OnboardingStepPageViewController: UIViewController, StoryboardLoadable {

    @IBOutlet weak var fbIcon: UIImageView!
    @IBOutlet weak var signUpWEmailButton: UIButton!
    @IBOutlet weak var alreadyHaveAccount: UIButton!
    @IBOutlet weak var signUpLaterButton: UIButton!
    @IBOutlet weak var signUpWFacebook: UIButton!
    @IBOutlet weak var menudLogo: UIImageView!

    var analyticsSessions: [String: Date] = [String: Date]()
    var foregroundImageName: String = "onboarding_menud_logo"

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.menudLogo.image = UIImage(named: self.foregroundImageName)
        self.configureSignUp()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startTracking()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.endTracking()
    }

    func configureSignUp() {
        signUpWFacebook.tintColor = UIColor.white
        signUpWFacebook.layer.cornerRadius = 3
        signUpWEmailButton.layer.cornerRadius = 3
        signUpWEmailButton.layer.borderColor = UIColor.white.cgColor
        signUpWEmailButton.layer.borderWidth = 2.0
    }

    @IBAction func fbSignUp(_ sender: Any) {
        if let fbURL = URL(string: Constant.authUrl + Constant.facebookAuthURL) as URL? {
            if (UIApplication.shared.openURL(fbURL)) {
                NotificationCenter.default.removeObserver(self)
                NotificationCenter.default.addObserver(self, selector: #selector(userHasLoggedIn), name: NSNotification.Name(rawValue: Constant.kUserHasLoggedIn), object: nil)
            }
        }
    }

    @IBAction func emailSignUp(_ sender: Any) {
        self.goToLogin(false)
    }

    @IBAction func signUpLater(_ sender: Any) {
        self.trackLoginSkip()
        AppStorage.shared.login {
            self.goToNextView()
        }
    }

    @objc func userHasLoggedIn() {
        NotificationCenter.default.removeObserver(self)
        self.goToNextView()
    }

    func goToNextView() {
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constant.kDidFinishWalkthrough), object: self)
    }

    func goToLogin(_ hasAccount: Bool) {
        let loginViewController = UIStoryboard.loadInitialViewController() as LoginViewController
        loginViewController.hasAccount = hasAccount
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }

}

extension OnboardingStepPageViewController: AnalyticsViewControllerProtocol {

    func getAnalyticsScreenName() -> String {
        return "Onboarding Sign Up"
    }

    func getAnalyticsProperties() -> [String: Any] {
        return ["onboarding": "sign"]
    }

}
