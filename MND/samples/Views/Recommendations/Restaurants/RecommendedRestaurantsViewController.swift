//
//  RecommendedRestaurantsViewController.swift
//  Menud
//
//  Created by Guilherme Hayashi on 10/08/2017.
//  Copyright © 2017 Macbook Pro. All rights reserved.
//

import Foundation
import CoreLocation
import SVProgressHUD

class RecommendedRestaurantsViewController: UIViewController, StoryboardLoadable {
    
    @IBOutlet weak var noRecommendationsView: UIView!
    @IBOutlet weak var recommendationsTableView: UITableView!
    
    //variables
    var userFilterScreens : SelectInfluencerViewController!
    var recommendRefreshControl : UIRefreshControl! = UIRefreshControl()
    var delegate: VenuesViewControllerDelegate?
    var interactor:Interactor = Interactor()
    lazy var presenter: RecommendedRestaurantsPresenter = RecommendedRestaurantsPresenter(view: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(recommendRefresh(_:)), name: NSNotification.Name(rawValue: Constant.kFirstLocationSent), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recommendRefresh(_:)), name: NSNotification.Name(rawValue: Constant.kUserHasLoggedIn), object: nil)

        self.recommendationsTableView.register(VenuesTableViewCell.self)
        self.recommendationsTableView.register(LoadingViewCell.self)
        self.recommendationsTableView.tableFooterView = UIView()
        self.recommendationsTableView.separatorStyle = .none
        self.recommendRefreshControl = UIRefreshControl()
        self.recommendRefreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        self.recommendRefreshControl.addTarget(self, action: #selector(recommendRefresh(_:)), for: UIControlEvents.valueChanged)
        self.recommendationsTableView.addSubview(self.recommendRefreshControl)
        self.loadRecommendations(refreshing: true, loadMore: false)
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
    
    @objc func recommendRefresh(_ sender:AnyObject){
        self.loadRecommendations(refreshing: true, loadMore: false)
    }
    
    func loadRecommendationsWithFilter(_ filter: FilterHolder) {
        self.loadRecommendations(refreshing: true, loadMore: false, filter: filter)
    }
    
    func loadRecommendations(refreshing: Bool, loadMore: Bool, filter: FilterHolder? = nil) {
        if !refreshing {
            SVProgressHUD.show()
        }
        
        self.presenter.getRecommendations(loadMore, filter) { (recommendations, error) in
            self.recommendationsTableView.reloadData()
            SVProgressHUD.dismiss()
            if (refreshing) {
                self.recommendRefreshControl.endRefreshing()
            }
        }
    }

}

extension RecommendedRestaurantsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.getRecomendationsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let venue = self.presenter.getVenueAtIndexPath(indexPath.row) {
            let cell = tableView.dequeueReusable(forIndexPath: indexPath) as VenuesTableViewCell
            cell.configure(venue, UserLocationManager.SharedManager.currentLocation)
            
            return cell
        }
        
        let cell = tableView.dequeueReusable(forIndexPath: indexPath) as LoadingViewCell
        cell.spinner.startAnimating()
        
        return cell
    }

}


extension RecommendedRestaurantsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (cell is LoadingViewCell) {
            self.loadRecommendations(refreshing: true, loadMore: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return VenuesTableViewCell.getHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let venue = self.presenter.getVenueAtIndexPath(indexPath.row) {
            let venueDetailsViewController = UIStoryboard.loadInitialViewController() as VenueDetailsViewController
            venueDetailsViewController.venue = venue
            venueDetailsViewController.transitioningDelegate = self
            venueDetailsViewController.interactor = self.interactor
            self.delegate?.incrementVenuesView()
            self.delegate?.trackNextController(venueDetailsViewController)
            self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
            self.navigationController?.pushViewController(venueDetailsViewController, animated: true)
        }
    }
    
}

extension RecommendedRestaurantsViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

