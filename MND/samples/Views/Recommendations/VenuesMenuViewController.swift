//
//  VenuesMenuViewController.swift
//  Menud
//
//  Created by Guilherme Hayashi on 24/10/2016.
//  Copyright © 2016 Macbook Pro. All rights reserved.
//

import CoreLocation

class VenuesMenuViewController : SlideMenuController {
    
    var analyticsSessions: [String : Date] = [String : Date]()
    var venuesViewController: RecommendationsViewController?
    var menuNavigationController: UINavigationController?
    var menuTableViewController: MainMenuViewController?
    var venuesViewCount = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func initVenuesMenuViewController(delegate: MainTabViewDelegate?) -> VenuesMenuViewController {
        SlideMenuOptions.rightViewWidth = UIScreen.main.bounds.width * 0.9
        SlideMenuOptions.simultaneousGestureRecognizers = false
        let centerNavigation = UIStoryboard.loadInitialViewController() as RecommendationsViewController
        centerNavigation.tabDelegate = delegate
        let rightController = UIStoryboard.loadInitialViewController() as MainMenuViewController
        let sliderController = VenuesMenuViewController(mainViewController: centerNavigation,rightMenuViewController: rightController.navigationController!)
        sliderController.removeRightGestures()

        return sliderController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        UserLocationManager.SharedManager.delegate = self
        self.venuesViewController = self.mainViewController as? RecommendationsViewController
        self.venuesViewController?.delegate = self
        self.menuNavigationController = self.rightViewController as? UINavigationController
        self.menuNavigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        self.menuNavigationController?.navigationBar.barTintColor = UIColor.menudBlueColor()
        self.menuNavigationController?.navigationBar.isTranslucent = false
        self.menuNavigationController?.navigationBar.tintColor = UIColor.white
        self.menuNavigationController?.navigationBar.topItem!.title = "Let's Work Some Magic..."
        self.menuNavigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "Lato-Bold", size: 20)!, NSAttributedStringKey.foregroundColor: UIColor.white]
        self.menuNavigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "close-filter-icon"), style: .done, target: self, action: #selector(closePressed(_:)))
        self.menuTableViewController = self.menuNavigationController?.childViewControllers[0] as? MainMenuViewController
        self.menuTableViewController?.delegate = self
        
        self.delegate = self.menuTableViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startTracking()
        self.venuesViewCount = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.endTracking()
        self.closeRight()
        self.trackVenueViews(self.venuesViewCount)
    }
    
    @objc func closePressed(_ sender: AnyObject) {
        self.closeRight()
    }
    
    func reloadRecommendations() {
        self.venuesViewController?.reloadRestaurants(filter: nil)
    }
    
    func clearLoadRecommendations() {
        AppStorage.shared.userSelectedTags.removeAll()
        self.reloadRecommendations()
    }

}

extension VenuesMenuViewController : UserLocationManagerDelegate {

    func locationManagerDidUpdateLocations(_ locations: [CLLocation]) {
        self.venuesViewController?.locationManagerDidUpdateLocations(locations)
        self.menuTableViewController?.locationManagerDidUpdateLocations(locations)
    }

}


extension VenuesMenuViewController : MainMenuViewControllerDelegate {

    func findRecommendationsWithFilter(_ filter: FilterHolder) {
        self.venuesViewController?.reloadRestaurants(filter: filter)
    }

}


extension VenuesMenuViewController: VenuesViewControllerDelegate {

    func dismissFilter() {
        self.navigationController?.popViewController(animated: true)
    }

    func openFilter() {
        self.openRight()
    }
    
    func incrementVenuesView() {
        self.venuesViewCount += 1
    }

    func trackNextController(_ nextController: AnalyticsViewControllerProtocol) {
        self.trackFlow(nextController)
    }

}

extension VenuesMenuViewController: AnalyticsViewControllerProtocol {

    func getAnalyticsProperties() -> [String: Any] {
        return ["type": "venue"]
    }
    
    func getAnalyticsScreenName() -> String {
        return "Venue List"
    }

}
