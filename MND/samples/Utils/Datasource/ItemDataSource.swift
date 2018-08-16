//
//  ItemDataSource.swift
//  MenuD
//
//  Created by Guilherme Hayashi on 17/04/2017.
//  Copyright © 2017 Macbook Pro. All rights reserved.
//

import Foundation
import RealmSwift

class ItemDataSource {
    
    static func favoriteItem(_ item: Item, isFavorite: Bool) {
        let realm = try! Realm()
        try! realm.write {
            item.isFavorite = isFavorite
        }
    }
    
}
