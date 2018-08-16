//
//  HomeViewController.swift
//  Menud
//
//  Created by Dario on 2/15/16.
//  Copyright © 2016 Macbook Pro. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import SVProgressHUD

protocol VenuesViewControllerDelegate {
    func openFilter()
    func incrementVenuesView()
    func trackNextController(_ nextController: AnalyticsViewControllerProtocol)
}

class RecommendationsViewController: UIViewController, UISearchBarDelegate, UITextFieldDelegate, StoryboardLoadable {

    @IBOutlet weak var keyHideView: UIView!
    @IBOutlet var recommendationsView: UIView!
    @IBOutlet weak var recipesView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var restaurantsViewController: RecommendedRestaurantsViewController?
    var mealsViewController: RecommendedMealsTableViewController?
    var userLocation : CLLocation?
    var delegate: VenuesViewControllerDelegate?
    var tabDelegate: MainTabViewDelegate?
    var interactor: Interactor = Interactor()
    var recommendationDelegate: RecommendedMealsDelegate?
    var drawer: AppDrawer? = nil
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.isNavigationBarHidden = true
        self.keyHideView.isHidden = true
        self.recipesView.isHidden = false
        self.segmentedControl.setCustomFont(name:Constant.FontFamily.SF_UI_Text, size: Constant.regularFontSize)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? RecommendedRestaurantsViewController {
            self.restaurantsViewController = controller
        }
        if let controller = segue.destination as? RecommendedMealsTableViewController {
            self.mealsViewController = controller
            self.mealsViewController?.delegate = recommendationDelegate
            self.mealsViewController?.tabDelegate = tabDelegate
        }
    }
    
    func filterClicked() {
        self.delegate?.openFilter()
    }

    // MARK: - Update Location Delegate
    func locationManagerDidUpdateLocations(_ locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(UserLocationManager.SharedManager.currentLocation!, completionHandler: {(placemarks, error)->Void in
            if (error != nil) {
                return
            }
            if placemarks!.count > 0 {
                _ = placemarks![0]
            } else {
            }
        })
    }

    func reloadRestaurants(filter: FilterHolder?) {
        self.restaurantsViewController?.loadRecommendations(refreshing: true, loadMore: false, filter: filter)
    }
    
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            drawer?.hideDrawer()
            self.diningOutClicked(sender)
        }
        else if sender.selectedSegmentIndex == 0 {
            drawer?.setDrawerPosition(position: .collapsed)
            drawer?.hideDrawer(false)
            self.stayingInClicked(sender)
        }
    }
    
    @IBAction func stayingInClicked(_ sender: Any) {
        self.recipesView.isHidden = false
        self.recommendationsView.isHidden = true
    }

    @IBAction func diningOutClicked(_ sender: Any) {
        self.recipesView.isHidden = true
        self.recommendationsView.isHidden = false
    }

}

extension RecommendationsViewController: InAppPurchaseAlertDelegate {
    
    func leftButtonPressed(_ alert: InAppPurchaseAlertViewController) {
        alert.dismiss(animated: true, completion: nil)
    }
    
    func rightButtonPressed(_ alert: InAppPurchaseAlertViewController) {
        alert.dismiss(animated: true, completion: nil)
    }
    
}


extension RecommendationsViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

