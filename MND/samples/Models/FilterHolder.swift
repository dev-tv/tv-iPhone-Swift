//
//  FilterHolder.swift
//  Menud
//
//  Created by Guilherme Hayashi on 24/10/2016.
//  Copyright © 2016 Macbook Pro. All rights reserved.
//

class FilterHolder: NSObject, NSCoding {
    var name: String!
    var cuisines: NSMutableArray!
    var vicinities: NSMutableArray!
    var prices: NSMutableArray!
    var sortBy: String!
    var zipCode: String!
    static let defaultFilterNames = ["My Go-To", "Healthy\nFavs", "Comfort\nFood"]
    static let pricesString = ["$", "$$", "$$$", "$$$$", "$$$$$"]
    static let spacing = "          "
    static let cuisineDefaultString = "Cuisine"
    static let vicinityDefaultString = "Neighborhood around me"
    static let priceDefaultString = "Price range"
    static let influencerDefaultString = "Influencer"
    
    init(index: Int = -1) {
        self.name = ""
        if (index >= 0) {
            self.name = FilterHolder.defaultFilterNames[index]
        }
        self.cuisines = []
        self.vicinities = []
        self.prices = []
        self.sortBy = ""
        self.zipCode = ""
        super.init()
    }

    func encode(with encoder: NSCoder) {
        encoder.encode(self.name, forKey: "name")
        encoder.encode(self.cuisines, forKey:"cuisines")
        encoder.encode(self.vicinities, forKey:"vicinities")
        encoder.encode(self.prices, forKey:"prices")
        encoder.encode(self.sortBy, forKey:"sortBy")
    }

    required init(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.cuisines = aDecoder.decodeObject(forKey: "cuisines") as! NSMutableArray
        self.vicinities = aDecoder.decodeObject(forKey: "vicinities") as! NSMutableArray
        self.prices = aDecoder.decodeObject(forKey: "prices") as! NSMutableArray
        self.sortBy = aDecoder.decodeObject(forKey: "sortBy") as! String
    }
    
    func getPriceLabel(_ priceData: String) -> String {
        let priceInt = Int(priceData)!
        return FilterHolder.pricesString[priceInt - 1]
    }
    
    func getCuisinesString() -> String {
        if (self.cuisines.count > 0) {
            self.cuisines = self.sortStringArray(self.cuisines)
            return self.cuisines.componentsJoined(by: FilterHolder.spacing)
        } else {
            return FilterHolder.cuisineDefaultString
        }
    }

    func getNeighborhoodsString() -> String {
        if (self.vicinities.count > 0) {
            self.vicinities = self.sortStringArray(self.vicinities)
            return self.vicinities.componentsJoined(by: FilterHolder.spacing)
        } else {
            return FilterHolder.vicinityDefaultString
        }
    }

    func getPricesString() -> String {
        let pricesArray : NSMutableArray = []
        if (self.prices.count > 0) {
            self.prices = self.sortStringArray(self.prices)
            for price in self.prices {
                let priceInt = Int(price as! String)!
                pricesArray.add(FilterHolder.pricesString[priceInt - 1])
            }
            return pricesArray.componentsJoined(by: FilterHolder.spacing)
        } else {
            return FilterHolder.priceDefaultString
        }
    }
    
    func sortStringArray(_ unsortedArray: NSMutableArray) -> NSMutableArray {
        return NSMutableArray.init(array: unsortedArray.sorted(by: { (string1, string2) -> Bool in
            return (string1 as! String) < (string2 as! String)
        }))
    }

    func toQuery() -> NSDictionary {
        let vicinitiesWithoutCity : NSMutableArray = []
        for vicinity in self.vicinities {
            let vicWithoutCity = (vicinity as! String).components(separatedBy: " - ")
            vicinitiesWithoutCity.add(vicWithoutCity[0])
        }
        return [
            "cuisines": self.cuisines,
            "vicinities": vicinitiesWithoutCity,
            "prices": self.prices,
            "sortBy": self.sortBy,
            "zipCode": self.zipCode
        ]
    }
}
