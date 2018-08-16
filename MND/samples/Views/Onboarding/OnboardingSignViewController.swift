//
//  OnboardingLaterViewController.swift
//  Menud
//
//  Created by Guilherme Hayashi on 27/07/2017.
//  Copyright © 2017 Macbook Pro. All rights reserved.
//

import Foundation

class OnboardingSignViewController: UIViewController, StoryboardLoadable {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.minimumScaleFactor = 0.5
        descriptionLabel.minimumScaleFactor = 0.5
        titleLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.adjustsFontSizeToFitWidth = true
    }
    
    
    @IBAction func signLaterClicked(_ sender: Any) {
        AppStorage.shared.login {
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constant.kDidFinishWalkthrough), object: self)
        }
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        let signController = UIStoryboard.loadInitialViewController() as OnboardingStepPageViewController
        self.navigationController?.pushViewController(signController, animated: true)
    }
    
}
