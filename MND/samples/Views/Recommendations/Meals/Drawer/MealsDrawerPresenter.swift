//
//  MealsDrawerPresenter.swift
//  Menud
//
//  Created by Guilherme Hayashi on 21/08/2017.
//  Copyright © 2017 Macbook Pro. All rights reserved.
//

import Foundation

class MealsDrawerPresenter {
    
    var view: MealsDrawerViewController
    var pinnedMeals: [Meal] = []
    var listMeals :[Meal] = []
    var selectedMeal: Meal?
    var currentFilter: String = ""
    
    init(view: MealsDrawerViewController) {
        self.view = view
        NotificationHelper.addObserver(Constant.kPreferencesLoaded) {
            self.update()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func update() {
        self.view.btnBreakfast.deSelectFilterButton()
        self.view.btnLunch.deSelectFilterButton()
        self.view.btnBreakfast.deSelectFilterButton()
        self.view.btnSnacks.deSelectFilterButton()
        self.pinnedMeals.removeAll()
        self.listMeals.removeAll()
        for mealKey in AppStorage.shared.userPinnedMeals.keys {
            if let meal = AppStorage.shared.userPinnedMeals[mealKey] {
                self.pinnedMeals.append(meal)
                self.listMeals.append(meal)
            }
        }
        self.view.updateView()
    }
    
    @objc func loadMeals() {
        self.update()
    }
    
    func updateFilterMeal(filter: String) {
        if self.currentFilter == filter {
            self.listMeals = pinnedMeals
            self.currentFilter = ""
        } else {
            self.currentFilter = filter
            self.listMeals = pinnedMeals.filter{$0.mealtypes.contains(filter)}
        }
        self.view.pinnedMealsCollectionView.reloadData()
        self.view.showEmptyView(show:listMeals.count == 0)
    }
    
    func searchMeal(text: String) {
        self.listMeals = pinnedMeals.filter{$0.name.contains(text) || $0.recipes.flatMap{$0.title.lowercased().contains(text)}.contains(true) || $0.tags.flatMap{$0.name?.lowercased().contains(text)}.contains(true) }
        self.view.pinnedMealsCollectionView.reloadData()
        self.view.showEmptyView(show:listMeals.count == 0)
    }
    
    func reloadAllMeals(){
        listMeals = pinnedMeals
        view.updateView()
    }
    func clearAllMeals(){
        if let user = Utilities.getCurrentUser(), let profileId = user.profile?.uid {
        BackendUtilities.unPinAllUserMeals(profileId, completionHandler: { error in
            if (error == nil) {
                self.pinnedMeals = []
                AppStorage.shared.userPinnedMeals = [:]
                self.update()
                Utilities.refreshPinedMeals()
            }
        })
        }
    }
}
