//
//  MainMenuViewController.swift
//  Menud
//
//  Created by Guilherme Hayashi on 24/10/2016.
//  Copyright © 2016 Macbook Pro. All rights reserved.
//

import CoreLocation

protocol MainMenuViewControllerDelegate {
    func findRecommendationsWithFilter(_ filter: FilterHolder)
}

protocol MainMenuViewDelegate {
    func updateFilterDataset(_ filter: FilterHolder)
}

enum MenuOptionType: Int {
    case presetName = 0
    case cuisine
    case neighborhood
    case price
    case sortBy

    static let allValues = [presetName, cuisine, neighborhood, price, sortBy]
}

class MainMenuViewController : UIViewController, MenuOptionsButtonsTableViewDelegate, SlideMenuControllerDelegate, MainMenuViewDelegate, StoryboardLoadable {
    
    @IBOutlet weak var menuTableView: UITableView!
    
    var analyticsSessions: [String: Date] = [String: Date]()
    var cuisinesDataSource: [String]?
    var neighborhoodDataSource: [String]?
    var pricesDataSource: [String]?
    var filters: [FilterHolder] = [FilterHolder]()
    var temporaryFilter: FilterHolder?
    var selectedIndex: Int = -1
    var isDataFetched = false
    var delegate: MainMenuViewControllerDelegate?

    let sortByDataSource: [String] = ["Nearest", "Name", "Price"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.filters = Utilities.getFilterHolders()
        self.temporaryFilter = FilterHolder(index: -1)
        if (self.filters.count == 0) {
            for i in 0..<3 {
                let filter = FilterHolder(index: i)
                self.filters.append(filter)
            }
        }
        self.cuisinesDataSource = [String]()
        self.neighborhoodDataSource = [String]()
        self.pricesDataSource = [String]()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.menuTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.menuTableView.tableFooterView = UIView()
        self.menuTableView.isScrollEnabled = false
    }


    
    func getSelectedFilter() -> FilterHolder {
        if (self.selectedIndex >= 0) {
            return self.filters[self.selectedIndex]
        }
        
        return self.temporaryFilter!
    }

    @IBAction func findButtonClicked(_ sender: AnyObject) {
        self.closeRight()
        self.delegate?.findRecommendationsWithFilter(getSelectedFilter())
    }
    
    // MARK: Update Location Delegate
    func locationManagerDidUpdateLocations(_ locations: [CLLocation]) {
        
    }

    // MARK: Filters Action Delegate
    func didClickButtonAtIndex(_ section: Int, index: Int, isSame: Bool) {
        if (section == MenuOptionType.presetName.rawValue) {
            if (isSame) {
                self.selectedIndex = -1
                self.temporaryFilter = FilterHolder(index: -1)
            } else {
                self.selectedIndex = index
            }
            self.menuTableView.reloadData()
        } else {
            if (!isSame) {
                getSelectedFilter().sortBy = self.sortByDataSource[index]
            } else {
                getSelectedFilter().sortBy = ""
            }
        }
    }
    
    func updateFilterDataset(_ filter: FilterHolder) {
        if (self.selectedIndex >= 0) {
            self.filters[self.selectedIndex] = filter
        } else {
            self.temporaryFilter = filter
        }
        self.menuTableView.reloadData()
    }
    
    // MARK: SlideMenuControllerDelegate
    func rightWillOpen() {
        self.startTracking()
        self.menuTableView.reloadData()
    }

    func rightDidClose() {
        self.endTracking()
        Utilities.saveFilterHolders(self.filters)
        self.navigationController?.popToRootViewController(animated: false)
    }
}


extension MainMenuViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section > 0) {
            return Constant.MenuOptionSmallCellHeight
        }
        
        return tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section > 0) {
            return Constant.MenuOptionDefaultCellHeight
        } else {
            return Constant.MenuOptionPresetCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell
        let sectionEnum = MenuOptionType.init(rawValue: indexPath.section)!
        if (sectionEnum == .presetName || sectionEnum == .sortBy) {
            let cellIdentifier = sectionEnum == .presetName ? "MenuOptionLargeButtonsTableViewCell"
                : "MenuOptionButtonsTableViewCell"
            let buttonsCell: MenuOptionButtonsTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! MenuOptionButtonsTableViewCell
            if (indexPath.section == 0) {
                buttonsCell.setupButtonLabels([self.filters[0].name, self.filters[1].name, self.filters[2].name])
                if (self.selectedIndex >= 0) {
                    buttonsCell.setSelectedButton(self.selectedIndex)
                }
            } else {
                buttonsCell.setupButtonLabels(self.sortByDataSource as NSArray)
                buttonsCell.deselectAllButtons()
                if (!self.getSelectedFilter().sortBy.isEmpty) {
                    buttonsCell.setSelectedButton(self.sortByDataSource.index(of: self.getSelectedFilter().sortBy)!)
                }
            }
            buttonsCell.inSection = indexPath.section
            buttonsCell.buttonsDelegate = self
            cell = buttonsCell
        } else {
            let optionCell: MenuRoundedOptionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MenuRoundedOptionTableViewCell") as! MenuRoundedOptionTableViewCell
            switch(sectionEnum) {
                case .cuisine:
                    optionCell.optionLabel.text! = self.getSelectedFilter().getCuisinesString()
                case .neighborhood:
                    optionCell.optionLabel.text! = self.getSelectedFilter().getNeighborhoodsString()
                case .price:
                    optionCell.optionLabel.text! = self.getSelectedFilter().getPricesString()
                default:
                    break
            }
            cell = optionCell
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "MenuOptionTableViewHeader") as! MenuOptionTableViewHeader
        let sectionEnum = MenuOptionType.init(rawValue: section)!
        switch (sectionEnum) {
        case .presetName:
            header.headerLabel.font = UIFont.init(name: "Lato-Bold", size: Constant.MenuLargeTitleFontSize)
            header.headerLabel.text = NSLocalizedString("preset_menu_title", comment: "")
        case .cuisine:
            header.headerLabel.text = NSLocalizedString("cuisine_menu_title", comment: "")
        case .neighborhood:
            header.headerLabel.text = NSLocalizedString("neighborhood_menu_title", comment: "")
        case .price:
            header.headerLabel.text = NSLocalizedString("price_menu_title", comment: "")
        case .sortBy:
            header.headerLabel.font = UIFont.init(name: "Lato-Bold", size: Constant.MenuLargeTitleFontSize)
            header.headerLabel.text = NSLocalizedString("sort_menu_title", comment: "")
        }
        
        return header
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return MenuOptionType.allValues.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionEnum = MenuOptionType(rawValue: indexPath.section)!
        if (sectionEnum != .presetName && sectionEnum != .sortBy) {
            let menuOptionController = MenuOptionTableViewController.MenuOptionControllerFromStoryboard()
            switch (sectionEnum) {
                case .cuisine:
                    menuOptionController.optionsDataSource = NSMutableArray.init(array: self.cuisinesDataSource!)
                case .neighborhood:
                    menuOptionController.optionsDataSource = NSMutableArray.init(array: self.neighborhoodDataSource!)
                case .price:
                    menuOptionController.optionsDataSource = NSMutableArray.init(array: self.pricesDataSource!)
                default:
                    break
            }
            menuOptionController.optionsType = sectionEnum
            menuOptionController.filter = self.getSelectedFilter()
            menuOptionController.delegate = self
            self.navigationController?.pushViewController(menuOptionController, animated: true)
        }
    }
}

extension MainMenuViewController: AnalyticsViewControllerProtocol {
    
    func getAnalyticsProperties() -> [String: Any] {
        return ["type": "venue"]
    }
    
    func getAnalyticsScreenName() -> String {
        return "Filter"
    }
}
