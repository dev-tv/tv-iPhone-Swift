//
//  OnboardingViewController.swift
//  Menud
//
//  Created by Guilherme Hayashi on 08/06/2017.
//  Copyright © 2017 Macbook Pro. All rights reserved.
//

import Foundation

class OnboardingViewController: UIViewController, StoryboardLoadable {
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var centerImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var skipLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    var iconImagePath: String?
    var centerImagePath: String?
    var titleText: String?
    var buttonText: String?
    
    var hasAccount = false
    var isLast = false
    var analyticsSessions: [String : Date] = [String: Date]()
    
    var onNext: (() -> ())? = nil
    var onSkip: (() -> ())? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        self.startTracking()
    }
    
    func setupView() {
        if let iconImagePath = self.iconImagePath, let titleText = self.titleText {
            iconImage.image = UIImage(named: iconImagePath)
            
            titleLabel.text = titleText
        }
        if let centerImagePath = self.centerImagePath {
            centerImage.setImageWith(URL(string: centerImagePath))
        }
        
        if let buttonText = self.buttonText {
            nextButton.setTitle(buttonText, for: .normal)
        }
        if (isLast) {
            skipLabel.isHidden = true
        } else {
            skipLabel.onClick {
                self.onSkip?()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.endTracking()
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        onNext?()
    }
    
    
    
}

extension OnboardingViewController: AnalyticsViewControllerProtocol {
    
    func getAnalyticsScreenName() -> String {
        return "Onboarding View"
    }

    func getAnalyticsProperties() -> [String: Any] {
        return ["onboarding_step": 0]
    }
}



