//
//  MealsDrawerViewController.swift
//  Menud
//
//  Created by Guilherme Hayashi on 09/08/2017.
//  Copyright © 2017 Macbook Pro. All rights reserved.
//

import Foundation
import Pulley

protocol MealsDrawerDelegate {
    func showPartialRevelead()
}

class MealsDrawerViewController: UIViewController, PulleyDrawerViewControllerDelegate, StoryboardLoadable {
    
    let drawerOriginalHeight: CGFloat = 55
    var drawerBarHeight: CGFloat = 55
    var drawerBodyHeight: CGFloat = 205
    var isPlanningView = false
    
    @IBOutlet weak var selectItemsLabel: UILabel!
    @IBOutlet weak var pinCountButton: UIButton!
    @IBOutlet weak var pinnedMealsCollectionView: UICollectionView!
    @IBOutlet weak var drawerIndicatorView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var dropView: UIView!
    @IBOutlet var pinCountView: UIView!
    @IBOutlet var filterView: UIView!
    @IBOutlet var filterButtonView: UIView!
    @IBOutlet var btnLunch: UIButton!
    @IBOutlet var btnBreakfast: UIButton!
    @IBOutlet var btnDinner: UIButton!
    @IBOutlet var btnSnacks: UIButton!
    @IBOutlet var btnClearPinboard: UIButton!
    @IBOutlet var btnSearch: UIButton!
    @IBOutlet var searchView: UIView!
    @IBOutlet var btnClearSearch: UIButton!
    @IBOutlet var txtSearchMeal: UITextField!
    
    
    var typingTimer: Timer?
    var isSearchEnable: Bool = false
    var keyBoardHeight: CGFloat = 0.0
    var interactor: Interactor? = nil
    var onMealSelected: ((Meal?) -> ())? = nil
    var selectedIndex: IndexPath? = nil
    
    lazy var presenter: MealsDrawerPresenter = MealsDrawerPresenter(view: self)
    var delegate: MealsDrawerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        if isPlanningView {
            dragAndDropSetup()
        }
    }
    
    func dragAndDropSetup() {
        if #available(iOS 11.0, *) {
            self.drawerBodyHeight = 205
            self.pinnedMealsCollectionView.dragDelegate = self
            self.pinnedMealsCollectionView.dragInteractionEnabled = true
            let dropInteraction = UIDropInteraction(delegate: self)
            self.dropView.addInteraction(dropInteraction)
            selectItemsLabel.text = "planning_select_items_ios_11".localized()
        } else {
            selectItemsLabel.text = "planning_select_items".localized()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateView()
        self.presenter.update()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillAppear(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.pinCountButton.round(pinCountButton.frame.size.width/2.0)
    }
    
    
    func setupView() {
        self.presenter.update()
        self.drawerIndicatorView.round(4)
        self.pinnedMealsCollectionView.register(RecipeCollectionViewCell.self)
        self.pinnedMealsCollectionView.showsHorizontalScrollIndicator = false
        self.setupLayout()
        
        filterButtonView.layer.cornerRadius = 4
        filterButtonView.layer.masksToBounds = true
        filterButtonView.layer.borderColor = UIColor.gray.cgColor
        filterButtonView.layer.borderWidth = 1
        
        searchView.layer.cornerRadius = 10
        searchView.layer.masksToBounds = true
        searchView.layer.borderColor = UIColor.gray.cgColor
        searchView.layer.borderWidth = 1
        txtSearchMeal.delegate = self
        btnLunch.filterButtonSetup()
        btnBreakfast.filterButtonSetup()
        btnDinner.filterButtonSetup()
        btnSnacks.filterButtonSetup()
    }
    
    func setupLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 180, height: 159)
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 4
        layout.scrollDirection = .horizontal
        pinnedMealsCollectionView.collectionViewLayout = layout
    }
    
    func showEmptyView(show: Bool) {
        self.emptyView.isHidden = !show
    }
    
    func collapsedDrawerHeight() -> CGFloat {
        return drawerBarHeight
    }
    
    func partialRevealDrawerHeight() -> CGFloat {
        
        let height = isSearchEnable ? drawerBodyHeight + keyBoardHeight : drawerBarHeight + drawerBodyHeight
        return height
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.collapsed, .partiallyRevealed]
    }
    
    func refreshPinnedMeals() {
        self.presenter.loadMeals()
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController) {
        if drawer.drawerPosition == .partiallyRevealed {
            pinCountView.isHidden = true
            filterView.isHidden = false
        }else {
            if isSearchEnable {
                self.view.endEditing(true)
            }else {
                pinCountView.isHidden = false
                filterView.isHidden = true
            }
        }
    }
    
    func onDragChange(_ isDraging: Bool) {
        self.dropView.isHidden = !isDraging
        self.pinnedMealsCollectionView.isHidden = isDraging
    }
    
    func updateView() {
        self.pinCountButton.setTitle("\(self.presenter.pinnedMeals.count)", for: .normal)
        self.showEmptyView(show: presenter.pinnedMeals.count == 0)
        self.pinnedMealsCollectionView.reloadData()
    }
    
    func hideDrawer(_ hide: Bool) {
        self.drawerBarHeight = hide ? 0 : drawerOriginalHeight
    }
    
    @IBAction func didClickStartPlanning(_ sender: Any) {
        if self.presenter.pinnedMeals.count > 0 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.showPlanning), object: nil)
        } else {
            self.delegate?.showPartialRevelead()
        }
    }
    
    @IBAction func didClickOnBreakFast(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            btnBreakfast.deSelectFilterButton()
        } else {
            sender.backgroundColor = Utilities.convertHexToRGB("#00538B")
        }
        btnLunch.deSelectFilterButton()
        btnDinner.deSelectFilterButton()
        btnSnacks.deSelectFilterButton()
        filter(sender: 1)
    }
    
    @IBAction func didClickOnLunch(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            btnLunch.deSelectFilterButton()
        } else {
            sender.backgroundColor = Utilities.convertHexToRGB("#00538B")
        }
        btnBreakfast.deSelectFilterButton()
        btnDinner.deSelectFilterButton()
        btnSnacks.deSelectFilterButton()
        filter(sender: 2)
    }
    
    @IBAction func didClickOnDinner(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            btnDinner.deSelectFilterButton()
        } else {
            sender.backgroundColor = Utilities.convertHexToRGB("#00538B")
        }
        btnLunch.deSelectFilterButton()
        btnBreakfast.deSelectFilterButton()
        btnSnacks.deSelectFilterButton()
        filter(sender: 3)
    }
    
    @IBAction func didClickOnSnacks(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            btnSnacks.deSelectFilterButton()
        } else {
            sender.backgroundColor = Utilities.convertHexToRGB("#00538B")
        }
        btnLunch.deSelectFilterButton()
        btnDinner.deSelectFilterButton()
        btnBreakfast.deSelectFilterButton()
        filter(sender: 4)
    }
    
    @IBAction func showSearchView(_ sender: UIButton) {
        searchView.isHidden = false
        txtSearchMeal.becomeFirstResponder()
        btnLunch.deSelectFilterButton()
        btnDinner.deSelectFilterButton()
        btnBreakfast.deSelectFilterButton()
        btnSnacks.deSelectFilterButton()
        presenter.reloadAllMeals()
    }
    
    @IBAction func clearSearchTextField(_ sender: UIButton) {
        txtSearchMeal.text = ""
        self.view.endEditing(true)
        presenter.reloadAllMeals()
    }
    
    @IBAction func clearAllPinBoardMeals(_ sender: UIButton) {
        if self.presenter.pinnedMeals.count != 0 {
            clearPinBoarListConfirmation()
        }
    }
    
    func filter(sender:Int){
        self.presenter.updateFilterMeal(filter:"\(sender)")
    }
    
    func clearPinBoarListConfirmation() {
        
        let alert = UIAlertController(title: "appDrawer_clear_alert_title".localized(), message: "appDrawer_clear_alert_message".localized(), preferredStyle: .alert)
        let clearAction = UIAlertAction(title: "grocery_weekly_clear_alert_clear".localized(), style: .default) { (alert: UIAlertAction!) -> Void in
            self.presenter.clearAllMeals()
        }
        let cancelAction = UIAlertAction(title: "grocery_clear_alert_cancel".localized(), style: .default)
        alert.addAction(cancelAction)
        alert.addAction(clearAction)
        
        present(alert, animated: true, completion:nil)
    }
    
    @objc func textSearch(_ timer: Timer) {
        if (txtSearchMeal.text?.isEmpty)!{
            presenter.reloadAllMeals()
        }else{
            self.presenter.searchMeal(text: (txtSearchMeal.text?.lowercased())!)
        }
    }
    
    @objc func keyboardWillAppear(notification: NSNotification){
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyBoardHeight = keyboardRectangle.height
            self.delegate?.showPartialRevelead()
        }
    }
    
}
extension MealsDrawerViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.typingTimer?.invalidate()
        self.typingTimer = nil
        self.typingTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(textSearch(_:)), userInfo: nil, repeats: false)
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isSearchEnable = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isSearchEnable = false
        searchView.isHidden = true
        self.delegate?.showPartialRevelead()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtSearchMeal.resignFirstResponder()
        return true
    }
}
extension MealsDrawerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.presenter.listMeals.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = pinnedMealsCollectionView.dequeueReusable(forIndexPath: indexPath) as RecipeCollectionViewCell
        cell.meal = self.presenter.listMeals[indexPath.row]
        return cell
    }
}

extension MealsDrawerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if isPlanningView {
            if self.selectedIndex == indexPath {
                collectionView.deselectItem(at: indexPath, animated: true)
                selectedIndex = nil
            } else {
                self.selectedIndex = indexPath
            }
            self.onMealSelected?(presenter.listMeals[indexPath.row])
        } else {
            guard let cell = collectionView.cellForItem(at: indexPath) as? RecipeCollectionViewCell else { return }
            let mealDetailsController = UIStoryboard.loadInitialViewController() as MealDetailsViewController
            mealDetailsController.interactor = interactor
            mealDetailsController.transitioningDelegate = transitioningDelegate
            mealDetailsController.presenter.setup(meal: cell.meal)
            self.navigationController?.pushViewController(AppDrawer(mealDetailsController), animated: true)
            collectionView.deselectItem(at: indexPath, animated: false)
        }
    }
    
}

@available(iOS 11.0, *)
extension MealsDrawerViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = self.presenter.listMeals[indexPath.row]
        let itemProvider = NSItemProvider(object: item.uid as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = DropMeal(meal: item)
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionIsRestrictedToDraggingApplication session: UIDragSession) -> Bool {
        return true
    }
    
}

@available(iOS 11.0, *)
extension MealsDrawerViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: String.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        if let dropMeal = session.items.first?.localObject as? DropMeal {
            dropMeal.action?()
        }
    }
    
}



