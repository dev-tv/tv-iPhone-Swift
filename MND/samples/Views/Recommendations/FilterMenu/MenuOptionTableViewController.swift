//
//  MenuOptionTableViewController.swift
//  Menud
//
//  Created by Guilherme Hayashi on 24/10/2016.
//  Copyright © 2016 Macbook Pro. All rights reserved.
//

class MenuOptionTableViewController : UIViewController {
    
    @IBOutlet weak var menuOptionTitleLabel: UILabel!
    @IBOutlet weak var optionsTableView: UITableView!
    var optionsDataSource: NSMutableArray?
    var optionsType: MenuOptionType?
    var filter: FilterHolder?
    var delegate: MainMenuViewDelegate?

    static func MenuOptionControllerFromStoryboard() -> MenuOptionTableViewController {
        let storyboard = UIStoryboard.init(name: "MainMenuViewController", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "MenuOptionTableViewController") as! MenuOptionTableViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.optionsTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.optionsTableView.tableFooterView = UIView()
        switch (self.optionsType!) {
            case .cuisine:
                self.menuOptionTitleLabel.text = NSLocalizedString("cuisine_menu_title", comment: "")
            case .neighborhood:
                self.menuOptionTitleLabel.text = NSLocalizedString("neighborhood_menu_title", comment: "")
            case .price:
                self.menuOptionTitleLabel.text = NSLocalizedString("price_menu_title", comment: "")
            default:
                break;
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.updateFilterDataset(self.filter!)
    }
    
    @IBAction func nextButtonClicked(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MenuOptionTableViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsDataSource!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.MenuOptionDefaultCellHeight * 0.8
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuOptionTableViewCell") as! MenuOptionTableViewCell
        let object = optionsDataSource?.object(at: indexPath.row)
        switch (self.optionsType!) {
            case .cuisine:
                cell.optionLabel.text = object as? String
            case .neighborhood:
                cell.optionLabel.text = object as? String
            case .price:
                cell.optionLabel.text = self.filter?.getPriceLabel(object as! String)
            default:
                break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let object = optionsDataSource?.object(at: indexPath.row)
        switch (self.optionsType!) {
            case .cuisine:
                if (self.filter?.cuisines.index(of: object as! String) != NSNotFound) {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
                }
            case .neighborhood:
                if (self.filter?.vicinities.index(of: object as! String) != NSNotFound) {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
                }
            case .price:
                if (self.filter?.prices.index(of: object as! String) != NSNotFound) {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
                }
            default:
                break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = optionsDataSource?.object(at: indexPath.row)
        switch (self.optionsType!) {
            case .cuisine:
                self.filter?.cuisines.add(object as! String)
            case .neighborhood:
                self.filter?.vicinities.add(object as! String)
            case .price:
                self.filter?.prices.add(object as! String)
            default:
                break
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let object = optionsDataSource?.object(at: indexPath.row)
        switch (self.optionsType!) {
            case .cuisine:
                self.filter?.cuisines.remove(object as! String)
            case .neighborhood:
                self.filter?.vicinities.remove(object as! String)
            case .price:
                self.filter?.prices.remove(object as! String)
            default:
                break
        }
    }

}
