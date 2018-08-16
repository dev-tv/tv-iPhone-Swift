//
//  RecommendedMealsPresenter.swift
//  Menud
//
//  Created by Guilherme Hayashi on 13/08/2017.
//  Copyright © 2017 Macbook Pro. All rights reserved.
//

import Foundation

class RecommendedMealsTablePresenter {
    
    var view: RecommendedMealsTableViewController
    var meals: [Meal] = []
    var mealTimes: [MealTime] = []
    var selectedMealTime: MealTime?
    var offset = 0
    var influencer: Tag?
    
    init(view: RecommendedMealsTableViewController) {
        self.view = view
        self.onLoadMealCategories()
    }
    
    func onMealTimeSelected(mealTime: MealTime?) {
        self.selectedMealTime = mealTime
        self.onLoadMeals()
    }
    
    func onLoadMeals() {
        let influencers: [Tag]?
        if let influencer = influencer {
            influencers = [influencer]
        }else{
            influencers = FollowProduct.shared.getFollowers()
        }
        BackendUtilities.getMeals(influencers: influencers, mealTime: self.selectedMealTime, offset: self.offset) { [weak weakSelf = self] (success, meals) in
            if let meals = meals, success {
                weakSelf?.meals = meals
                weakSelf?.view.updateMealsTable()
            }
        }
        
    }
    
    func onLoadMealCategories() {
        BackendUtilities.getMealTimes { [weak weakSelf = self] (success, mealTimes) in
            if let mealTimes = mealTimes, success {
                let all = MealTime()
                all.name = "All"
                weakSelf?.mealTimes = [all] + mealTimes
                weakSelf?.onLoadMeals()
            }
        }
    }
    
    func onPinMeal(mealId: String, completion:((Bool)->())?) {
        if let user = Utilities.getCurrentUser(), let profileId = user.profile?.uid {
            completion?(true)
            BackendUtilities.pinUserMeal(profileId, mealId: mealId, completionHandler: { (error) in
                if (error != nil) {
                    completion?(false)
                }
            })
        }
    }
    
    func onUnpinMeal(mealId: String, completion:((Bool)->())?) {
        if let user = Utilities.getCurrentUser(), let profileId = user.profile?.uid {
            completion?(true)
            BackendUtilities.delUserMeal(profileId, mealId: mealId, completionHandler: { (error) in
                if (error != nil) {
                    completion?(false)
                }
            })
        }
    }
    
}
