//
//  Category.swift
//  Menud
//
//  Created by Dario on 2/22/16.
//  Copyright © 2016 Macbook Pro. All rights reserved.
//
import RealmSwift

class Category: Object {

    @objc dynamic var uid: String = "0.0"
    @objc dynamic var name: String?
    @objc dynamic var udescription: String?
    @objc dynamic var image: String?
    @objc dynamic var headerImage: String?
    @objc dynamic var menuId: NSNumber = 0.0
    let items: List<Item> = List<Item>()
    
    override static func primaryKey() -> String {
        return "uid"
    }
    
    convenience init(json: [String: Any]) {
        self.init()
        if let numberId = json["id"] as? NSNumber {
            self.uid = "\(numberId)"
        }
        self.name = json["name"] as! String!
        self.udescription = json["description"] as? String
        self.image = json["image"] as? String
        self.headerImage = json["headerImage"] as? String
        
        if let items = json["items"] as? [[String: Any]] {
            for item in items {
                let it = Item.init(json: item)
                self.items.append(it)
            }
        }
    }

}
