//
//  OnboardingTabViewController.swift
//  MenuD
//
//  Created by Adson Pereira Leal on 07/11/17.
//  Copyright © 2017 Macbook Pro. All rights reserved.
//

import UIKit
import Tabman
import Pageboy

class OnboardingTabViewController: TabmanViewController {

    override func viewDidLoad() {
        self.showsPageControl = true
        super.viewDidLoad()
        self.dataSource = self
        self.view.backgroundColor = Utilities.convertHexToRGB("#f7f7f7")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func setupProgress() {
        let barProgress = UIView.loadViewFromNib() as BarProgress
        let progressFrame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: view.frame.width, height: 4)
        barProgress.frame = progressFrame
        self.view.addSubview(barProgress)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}


extension OnboardingTabViewController : PageboyViewControllerDataSource {

    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        self.customPageControlIndicator(pageboyViewController)
        return 4
    }

    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        let vcFunctions = [
            { self.getVC(title: "onboarding_healthy_food".localized(), iconImage: "influencerDark", centerImage: Constant.onboardingInfluencerPath) },
            { self.getVC(centerImage: Constant.onboardingPlanningPath) },
            { self.getVC(title: "onboarding_find_meals".localized(), iconImage: "venuesIcon", centerImage: Constant.onboardingVenuePath) },
            { self.getVC(title: "onboarding_grocery_title".localized(), iconImage: "groceryIcon", centerImage: Constant.onboardingGroceryPath, buttonText: "onboarding_get_started".localized(), isLast: true) }
        ]

        return vcFunctions[index]()
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {

        return .first
    }


    func getVC(title: String? = nil, iconImage: String? = nil, centerImage: String, buttonText: String? = nil, isLast: Bool = false) -> UIViewController {
        let viewController = UIStoryboard.loadInitialViewController() as OnboardingViewController
        let onNext = {
            let signController = UIStoryboard.loadInitialViewController() as OnboardingSignViewController
            self.navigationController?.pushViewController(signController, animated: true)
        }
        let cacheImages = UIImageView()
        cacheImages.setImageWith(URL(string: centerImage))
        viewController.centerImagePath = centerImage
        viewController.iconImagePath = iconImage
        viewController.titleText = title
        viewController.buttonText = buttonText
        viewController.onSkip = onNext
        if isLast {
            viewController.onNext = onNext
            viewController.isLast = true
        } else {
            viewController.onNext = {
                self.scrollToPage(.next, animated: true)
            }
        }
        return viewController
    }


    func customPageControlIndicator(_ pageboyViewController:PageboyViewController) {
        if pageboyViewController.childViewControllers.count > 0 {
            for view in pageboyViewController.childViewControllers[0].view.subviews {
                if view is UIPageControl {
                    if let view = view as? UIPageControl {
                        view.pageIndicatorTintColor = UIColor.lightGray
                        view.currentPageIndicatorTintColor = UIColor.darkGray
                    }
                }
            }
        }
    }

}
