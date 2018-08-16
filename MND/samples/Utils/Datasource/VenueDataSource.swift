//
//  VenueDataSource.swift
//  MenuD
//
//  Created by Guilherme Hayashi on 03/04/2017.
//  Copyright © 2017 Macbook Pro. All rights reserved.
//

import Foundation
import RealmSwift

class VenueDataSource {

    static func saveVenues(_ venues: [Venue], initialIndex: Int = 0) {
        let realm = try! Realm()
        try! realm.write {
            var order = initialIndex
            for venue in venues {
                venue.requestOrder = order
                realm.add(venue, update: true)
                order += 1
            }
        }
    }
    
    static func getVenue(_ id: String) -> Venue? {
        let realm = try! Realm()
        return realm.objects(Venue.self).filter("uid == '\(id)'").first
    }
    
    static func getVenues() -> [Venue]? {
        let realm = try! Realm()
        let venues = realm.objects(Venue.self).sorted(byKeyPath: "requestOrder", ascending: true)
        
        return Array(venues)
    }
    
    static func clearVenues() {
        let realm = try! Realm()
        try! realm.write({ 
            let venues = realm.objects(Venue.self)
            for venue in venues {
                realm.delete(venue)
            }
        })
    }

}
