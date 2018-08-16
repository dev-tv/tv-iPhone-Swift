//
//  RecommendedMealsTableViewController.swift
//  Menud
//
//  Created by Guilherme Hayashi on 13/08/2017.
//  Copyright © 2017 Macbook Pro. All rights reserved.
//

import Foundation
import UIKit

class RecommendedMealsTableViewController: UIViewController, StoryboardLoadable {
    
    @IBOutlet weak var mealsTableView: UITableView!
    lazy var presenter: RecommendedMealsTablePresenter = RecommendedMealsTablePresenter(view: self)
    var delegate: RecommendedMealsDelegate?
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var notFollowingAction: (() -> ())? = nil
    var noInfluencersView: NoInfluencersView?
    var tabDelegate: MainTabViewDelegate?
    var isPremiumSubscribed: Bool = false
    var interactor: Interactor?
    var influencer: Tag? {
        didSet {
            presenter.influencer = influencer
            isPremiumSubscribed = FollowProduct.shared.isPremiumSubscribed(self.influencer!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNotFollowingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mealsTableView.reloadData()
    }
    
    func setupNotFollowingView(){
        if FollowProduct.shared.haveInfluencers || influencer != nil {
            noInfluencersView?.removeFromSuperview()
        }else if noInfluencersView == nil {
            if let noInfluencersView = UIView.loadViewFromNib("NoInfluencersView") as? NoInfluencersView{
                self.noInfluencersView = noInfluencersView
                noInfluencersView.findInfluencerButton.onClick {
                    self.tabDelegate?.goToInfluencers()
                }
                noInfluencersView.frame = self.view.frame
                self.view.addSubview(noInfluencersView)
            }
        }
    }
    
    func setupView() {
        self.mealsTableView.register(RecipeCategoriesTableViewCell.self)
        self.mealsTableView.register(RecipeTableViewCell.self)
        self.mealsTableView.register(LoadingViewCell.self)
        self.refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        self.refreshControl.addTarget(self, action: #selector(recommendRefresh), for: UIControlEvents.valueChanged)
        self.mealsTableView.addSubview(self.refreshControl)
        self.mealsTableView.tableFooterView = UIView()
        self.mealsTableView.separatorStyle = .none
        self.mealsTableView.delegate = self
        self.mealsTableView.dataSource = self
        self.mealsTableView.contentInset = UIEdgeInsetsMake(0, 0, 70, 0)
    }
    
    @objc func recommendRefresh() {
        self.presenter.onLoadMeals()
    }
    
    func updateMealsTable() {
        self.refreshControl.endRefreshing()
        self.mealsTableView?.reloadData()
    }
    
}

extension RecommendedMealsTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0   {
            return 1
        }
        return self.presenter.meals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0  {
            let header = tableView.dequeueReusable(forIndexPath: indexPath) as RecipeCategoriesTableViewCell
            header.mealTimes = self.presenter.mealTimes
            if (header.delegate == nil && self.presenter.mealTimes.count > 0) {
                header.delegate = self
                header.categoriesCollectionView.reloadData()
            }
            return header
        }else{
            let cell = tableView.dequeueReusable(forIndexPath: indexPath) as RecipeTableViewCell
            cell.meal = self.presenter.meals[indexPath.row]
            cell.selectionStyle = .none
            cell.delegate = self
            if influencer != nil && !isPremiumSubscribed {
                cell.removePinOptions()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0){
            return RecipeCategoriesTableViewCell.getHeight()
        }
        return RecipeTableViewCell.getHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isPremiumSubscribed {
            notFollowingAction?()
        }
        if influencer == nil || isPremiumSubscribed {
            guard let cell = tableView.cellForRow(at: indexPath) as? RecipeTableViewCell else { return }
            let mealDetailsController = UIStoryboard.loadInitialViewController() as MealDetailsViewController
            mealDetailsController.presenter.setup(meal: cell.meal)
            mealDetailsController.presenter.cell = cell
            mealDetailsController.presenter.delegate = self
            mealDetailsController.interactor = interactor
            mealDetailsController.transitioningDelegate = transitioningDelegate
            if let name = influencer?.name {
                mealDetailsController.presenter.influencerName = name
            } else {
                if let name = cell.meal?.tags.first?.name {
                    mealDetailsController.presenter.influencerName = name
                }
            }
            self.navigationController?.pushViewController(AppDrawer(mealDetailsController), animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
}

extension RecommendedMealsTableViewController: RecipeCategoriesTableViewCellDelegate {
    
    func onCategorySelected(cell: RecipeCategoryCollectionViewCell) {
        if let mealTime = cell.mealTime {
            self.presenter.onMealTimeSelected(mealTime: mealTime)
        }
    }
    
}

extension RecommendedMealsTableViewController: RecipeTableViewCellDelegate {
    
    private func changeMealState(_ cell: RecipeTableViewCell, _ meal: Meal, _ pinned: Bool){
        if pinned {
            AppStorage.shared.userPinnedMeals[meal.uid] = meal
            self.delegate?.onPinMeal(meal: meal)
        } else {
            AppStorage.shared.userPinnedMeals.removeValue(forKey: meal.uid)
            self.delegate?.onUnpinMeal(meal: meal)
        }
        cell.setupPinButton()
        Utilities.refreshPinedMeals()
    }
    
    func onPinMeal(cell: RecipeTableViewCell) {
        guard let meal = cell.meal else { return }
        self.presenter.onPinMeal(mealId: meal.uid) { success in
            self.changeMealState(cell, meal, success)
        }
    }
    
    func onUnpinMeal(cell: RecipeTableViewCell) {
        guard let meal = cell.meal else { return }
        self.presenter.onUnpinMeal(mealId: meal.uid) { success in
            self.changeMealState(cell, meal, !success)
        }
    }
    
}
