//
//  TagDataSource.swift
//  MenuD
//
//  Created by Guilherme Hayashi on 30/03/2017.
//  Copyright © 2017 Macbook Pro. All rights reserved.
//

import Foundation
import RealmSwift

class TagDataSource {
    
    static func getInfluencers() -> [Tag]? {
        let realm = try! Realm()
        let results = realm.objects(Tag.self).filter("tagType == 'influencer'").sorted(byKeyPath: "requestOrder", ascending: true)

        return Array(results)
    }
    
    static func getInfluencerById(_ id: String) -> Tag? {
        let realm = try! Realm()
        return realm.objects(Tag.self).filter("uid == '\(id)'").first
    }
    
    static func getInfluencerByProductId(_ productId: String) -> Tag? {
        let realm = try! Realm()
        return realm.objects(Tag.self).filter("profile.productId == '\(productId)'").first
    }
    
    static func saveInfluencers(_ influencers: [Tag], initialIndex: Int = 0) {
        let realm = try! Realm()
        try! realm.write({
            var order = initialIndex
            for influencer in influencers {
                influencer.requestOrder = order
                realm.add(influencer, update: true)
                order += 1
            }
        })
    }
    
    static func removeAll(){
        let realm = try! Realm()
        try! realm.write({
            let influencers = realm.objects(Tag.self).filter("tagType == 'influencer'").sorted(byKeyPath: "requestOrder", ascending: true)
            realm.delete(influencers)
        })
        
    }
    
}
