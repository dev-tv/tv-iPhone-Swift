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

class VenuesViewController: UIViewController, UISearchBarDelegate, UITextFieldDelegate {

    @IBOutlet weak var noRecommendationsView: UIView!
    @IBOutlet weak var keyHideView: UIView!
    @IBOutlet var recommendationsView: UIView!
    @IBOutlet weak var headerViewNew: UIView!
    @IBOutlet weak var recommendationsTableView: UITableView!
    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var alertHeaderView: AlertHeaderView!

    @IBOutlet weak var alertViewHeightConstraint: NSLayoutConstraint!
    var userFilterScreens : SelectInfluencerViewController!
    var recommendRefreshControl : UIRefreshControl! = UIRefreshControl()
    var venuesViewModel: VenuesViewModel!
    var keyboardShow : Bool = false
    var timer : Timer = Timer()
    var userLocation : CLLocation?
    var totalPages : Int = 0
    var recommendationsCurrentPage : Int = 0
    var recommendationsTotalPages : Int = 0
    var ignoreZipcodeAlert:Bool = UserLocationManager.SharedManager.isLocationAuthorized()
    var currentLatitude : String = "NULL"
    var currentLongitude : String = "NULL"
    let kVenuesPerPage = 10
    let kRecommendationsPerPage = 5
    var currentFilter: FilterHolder?
    var delegate: VenuesViewControllerDelegate?
    var interactor:Interactor = Interactor()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.venuesViewModel = VenuesViewModel()
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.isNavigationBarHidden = true
        self.timer = Timer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(recommendRefresh(_:)), name: NSNotification.Name(rawValue: Constant.kUserHasLoggedIn), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recommendRefresh(_:)), name: NSNotification.Name(rawValue: Constant.kFirstLocationSent), object: nil)

        self.keyHideView.isHidden = true
        self.recommendationsView.isHidden = false
        self.recommendationsTableView.register(VenuesTableViewCell.self)
        self.recommendationsTableView.register(LoadingViewCell.self)
        self.recommendationsTableView.tableFooterView = UIView()
        self.recommendationsTableView.separatorStyle = .none
        self.recommendRefreshControl = UIRefreshControl()
        self.recommendRefreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        self.recommendRefreshControl.addTarget(self, action: #selector(VenuesViewController.recommendRefresh(_:)), for: UIControlEvents.valueChanged)
        self.recommendationsTableView.addSubview(self.recommendRefreshControl)
        self.alertHeaderView.delegate = self
        
        let filterGesture = UITapGestureRecognizer.init(target: self, action: #selector(filterClicked))
        self.filterView.addGestureRecognizer(filterGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.ignoreZipcodeAlert = UserLocationManager.SharedManager.isLocationAuthorized()
        self.setAlertHeader(show: !self.ignoreZipcodeAlert)
    }
    
    func filterClicked() {
        self.delegate?.openFilter()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (!AppStorage.shared.loadInitialInfluencers) && (Utilities.getCurrentUser() != nil) {
            AppStorage.shared.loadInitialInfluencers = true
        }
    }
    
    func loadRecommendationsWithFilter(_ filter: FilterHolder) {
        self.currentFilter = filter
        self.recommendationsCurrentPage = 1
        self.loadRecommendations(self.kRecommendationsPerPage, skip: (self.recommendationsCurrentPage - 1) * self.kRecommendationsPerPage, refreshing: true)
    }
    
    func loadRecommendations(_ limit: Int, skip: Int, refreshing: Bool) {
        if !refreshing {
            SVProgressHUD.show()
        }
        
        self.userLocation = UserLocationManager.SharedManager.currentLocation
        if let userLocation = self.userLocation, skip == 0 {
            self.currentLatitude = userLocation.coordinate.latitude.description
            self.currentLongitude = userLocation.coordinate.longitude.description
        }
        self.venuesViewModel.getRecommendations("", limit: limit, skip: skip, latitude: self.currentLatitude, longitude: self.currentLongitude, filter: self.currentFilter){(recommendations, error) in
            if (error == nil) {
                self.recommendationsTotalPages = self.venuesViewModel.getTotalRecommendationsPage(self.kRecommendationsPerPage)
                self.recommendationsTableView.reloadData()
            } else if (recommendations != nil) {
                self.recommendationsTotalPages = 1
                self.recommendationsTableView.reloadData()
            }
            if self.venuesViewModel.getRecomendationsCount() > 0 {
                self.noRecommendationsView.isHidden = true
            } else {
                self.noRecommendationsView.isHidden = false
            }

            SVProgressHUD.dismiss()
            if (refreshing) {
                self.recommendRefreshControl.endRefreshing()
            }
        }
    }
    
    func promptForZipcode() {
        let zipcodeModal = UIStoryboard.loadInitialViewController() as ZipCodeViewController
        zipcodeModal.delegate = self
        zipcodeModal.modalPresentationStyle = .overFullScreen
        self.present(zipcodeModal, animated: true, completion: nil)
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
    
    // MARK: - Private methods
    func recommendRefresh(_ sender:AnyObject){
        if (ignoreZipcodeAlert) {
            if let zipFilter = self.currentFilter?.zipCode {
                if (zipFilter.characters.count < 5){
                    self.currentFilter = nil
                }
            }
        }
        self.recommendationsCurrentPage = 1
        self.loadRecommendations(self.kRecommendationsPerPage, skip: (self.recommendationsCurrentPage - 1) * self.kRecommendationsPerPage, refreshing: true)
    }

    func setAlertHeader(show: Bool) {
        self.alertHeaderView.show(show)
        if (show) {
            self.alertViewHeightConstraint.constant = AlertHeaderView.getHeight()
        } else {
            self.alertViewHeightConstraint.constant = 0
        }
    }

}


