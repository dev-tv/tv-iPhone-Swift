//
//  OnboardingWalkthrough.swift
//  Menud
//
//  Created by Guilherme Hayashi on 05/10/2016.
//  Copyright © 2016 Macbook Pro. All rights reserved.
//

import AVKit
import AVFoundation
//import Instabug
import UIKit

class OnboardingWalkthrough {
    
    static let initialTabKey = "initialTabKey"
    static var isOnboardingDone: Bool {
        return UserDefaults.standard.bool(forKey: Constant.kMustShowWalkthrough)
    }
    var appDelegate : AppDelegate?
    var nextViewController : LoginStoryboard
    
    func showWalkthrough() -> Bool {
        var show = false
        if (!OnboardingWalkthrough.isOnboardingDone) {
            NotificationCenter.default.addObserver(self, selector: #selector(didFinishOnboarding(_:)), name: NSNotification.Name(rawValue: Constant.kDidFinishWalkthrough), object: nil)
            let navigation = UINavigationController()
            navigation.navigationBar.isHidden = true
            navigation.viewControllers = [OnboardingTabViewController()]
            self.appDelegate!.window?.rootViewController = navigation
            show = true
        } else {
            self.appDelegate!.window?.rootViewController = self.nextViewController
        }
        self.appDelegate!.window?.makeKeyAndVisible()
        
        return show
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didFinishOnboarding(_ notification: Notification) {
        UserDefaults.standard.set(true, forKey: Constant.kMustShowWalkthrough)
        if let userInfo = notification.userInfo as? [String: AnyObject], let initialId = userInfo[OnboardingWalkthrough.initialTabKey] as? Int, let initialTab = MainTabItem(rawValue: initialId) {
            self.nextViewController?.initialIndex = initialTab
        }
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.transitionFlipFromRight, animations: {
            self.appDelegate!.window?.rootViewController = self.nextViewController
        }) { (success) in

        }
    }

}
