//
//  Category.swift
//  Menud
//
//  Created by Dario on 2/22/16.
//  Copyright © 2016 Macbook Pro. All rights reserved.
//
import Foundation

class PlanDay {
    
    @objc dynamic var date: Date = Date()
    var meals: [Meal] = []
    
    convenience init(json: [String: Any]) {
        self.init()
        if let mealsJson = json["meals"] as? [[String: Any]] {
            for meal in mealsJson {
                meals.append(Meal.init(json: meal))
            }
        }
        if let dateString = json["date"] as? String, let parsedDate = dateString.components(separatedBy: "T")[0].asDate {
            date = parsedDate
        }
    }
    
    convenience init(_ date: Date, _ meals: [Meal]) {
        self.init()
        self.date = date.startOfDay
        self.meals = meals
    }
    
    func mapToDict() -> [String: Any] {
        return [
            "date": self.date.dateStringWithFormat("YYYY-MM-dd"),
            "mealsIds": self.meals.map({Int($0.uid)})
        ]
    }
    
}
