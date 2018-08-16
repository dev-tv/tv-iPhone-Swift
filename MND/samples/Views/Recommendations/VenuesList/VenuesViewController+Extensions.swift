//
//  VenuesViewController+Extensions.swift
//  MenuD
//
//  Created by Guilherme Hayashi on 22/12/2016.
//  Copyright © 2016 Macbook Pro. All rights reserved.
//

extension VenuesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.recommendationsCurrentPage == 0) {
            return 1
        }
        if (self.recommendationsCurrentPage < self.recommendationsTotalPages) {
            return self.venuesViewModel.getRecomendationsCount() + 1
        }
        
        return self.venuesViewModel.getRecomendationsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row < self.venuesViewModel.getRecomendationsCount()) {
            let cell = tableView.dequeueReusable(forIndexPath: indexPath) as VenuesTableViewCell
            if let venue = self.venuesViewModel.getRecommendationVenue(indexPath.row) {
                cell.configure(venue)
                
                if self.venuesViewModel.getRecommendedVenueLocationByIndex(indexPath.row) != nil && self.userLocation != nil {
                    let meters = (self.userLocation?.distance(from: self.venuesViewModel.getRecommendedVenueLocationByIndex(indexPath.row)!))!
                    cell.setDistance(meters)
                }
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusable(forIndexPath: indexPath) as LoadingViewCell
        cell.spinner.startAnimating()
        
        return cell
    }
}


extension VenuesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (cell is LoadingViewCell) {
            self.recommendationsCurrentPage += 1
            self.loadRecommendations(self.kRecommendationsPerPage, skip: (self.recommendationsCurrentPage - 1) * self.kRecommendationsPerPage, refreshing: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return VenuesTableViewCell.getHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row < self.venuesViewModel.getRecomendationsCount()) {
            let cell = tableView.cellForRow(at: indexPath) as! VenuesTableViewCell
            let venueDetailsViewController = UIStoryboard.loadInitialViewController() as VenueDetailsViewController
            venueDetailsViewController.venue = cell.venue
            venueDetailsViewController.transitioningDelegate = self
            venueDetailsViewController.interactor = self.interactor
            self.delegate?.incrementVenuesView()
            self.delegate?.trackNextController(venueDetailsViewController)
            self.present(venueDetailsViewController, animated: true, completion: nil)
            
        }
    }
    
}

extension VenuesViewController: InAppPurchaseAlertDelegate {
    
    func leftButtonPressed(_ alert: InAppPurchaseAlertViewController) {
        alert.dismiss(animated: true, completion: nil)
    }
    
    func rightButtonPressed(_ alert: InAppPurchaseAlertViewController) {
        alert.dismiss(animated: true, completion: nil)
    }
    
}

extension VenuesViewController: AlertHeaderViewDelegate {
    
    func didCloseZipcodeAlert(_ alert: AlertHeaderView) {
        self.ignoreZipcodeAlert = true
        self.setAlertHeader(show: false)
    }
    
    func didTapAlert(_ alert: AlertHeaderView) {
        self.promptForZipcode()
    }
}

extension VenuesViewController: ZipCodeModalProtocol {

    func didEnterZip(zip: String) {
        let filter = FilterHolder()
        filter.zipCode = zip
        self.currentFilter = filter
        self.setAlertHeader(show: false)
        self.loadRecommendationsWithFilter(filter)
    }
    
}

extension VenuesViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
