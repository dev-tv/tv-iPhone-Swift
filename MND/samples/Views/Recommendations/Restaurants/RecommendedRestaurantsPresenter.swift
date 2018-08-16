//
//  RecommendedRestaurantsPresenter.swift
//  Menud
//
//  Created by Guilherme Hayashi on 12/08/2017.
//  Copyright © 2017 Macbook Pro. All rights reserved.
//

import Foundation
import CoreLocation

class RecommendedRestaurantsPresenter {
    
    //variables
    var view: RecommendedRestaurantsViewController
    var recommendations: NSMutableArray? = NSMutableArray()
    var currentPage : Int = 0
    let kVenuesPerPage = 10
    var recommendationTotal : Int = 0
    var currentLatitude : String = "NULL"
    var currentLongitude : String = "NULL"
    var currentFilter: FilterHolder?
    
    init(view: RecommendedRestaurantsViewController) {
        self.view = view
    }
    
    func getRecommendations(_ loadMore: Bool = false, _ filterHolder: FilterHolder? = nil, completion: @escaping ([Venue]?, Error?)->()) {
        if (loadMore) {
            self.currentPage += 1
        } else {
            self.currentPage = 0
        }
        if let userLocation = UserLocationManager.SharedManager.currentLocation, currentPage == 0 {
            self.currentLatitude = userLocation.coordinate.latitude.description
            self.currentLongitude = userLocation.coordinate.longitude.description
        }
        self.currentFilter = filterHolder
        
        self.getRecommendations("", limit: self.kVenuesPerPage, skip: self.currentPage * self.kVenuesPerPage, latitude: self.currentLatitude, longitude: self.currentLongitude, filter: self.currentFilter, completionHandler: completion)
    }
    
    func getRecommendations(_ stringQuery: String, limit: Int, skip: Int, latitude: String, longitude: String, filter: FilterHolder?, completionHandler:@escaping ([Venue]?, Error?)->()){
        BackendUtilities.getRecommendation(stringQuery, limit: limit, skip: skip, latitude: latitude, longitude: longitude, filter: filter) { (recommendedVenues, recommendationTotal, error) in
            if let recommendedVenues = recommendedVenues, error == nil {
                self.recommendationTotal = recommendationTotal
                if (skip == 0) {
                    VenueDataSource.clearVenues()
                    self.recommendations = NSMutableArray()
                }
                for venue in recommendedVenues {
                    self.recommendations?.add(venue)
                }
                VenueDataSource.saveVenues(recommendedVenues, initialIndex: skip)

                completionHandler(recommendedVenues, nil)
            } else {
                self.recommendations = NSMutableArray()
                if let venues = VenueDataSource.getVenues() {
                    for venue in venues {
                        self.recommendations?.add(venue)
                    }
                    self.recommendationTotal = venues.count
                    completionHandler(venues, error)
                }
            }
        }
        
    }
    
    func getVenueAtIndexPath(_ indexPath: Int) -> Venue? {
        if let recommendations = self.recommendations, indexPath < recommendations.count {
            return recommendations[indexPath] as? Venue
        }
        return nil
    }
    
    func getRecomendationsCount() -> Int {
        if let recommendations = self.recommendations {
            if (recommendations.count < self.recommendationTotal) {
                return recommendations.count + 1
            }
            return recommendations.count
        }
        return 0
    }
    
    func onConfigure(cell: VenuesTableViewCell, index: Int) {
        if let recommendations = self.recommendations, let venue = recommendations[index] as? Venue {
            cell.configure(venue, UserLocationManager.SharedManager.currentLocation)
        }
    }
    
}
