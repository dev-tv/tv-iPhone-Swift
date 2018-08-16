//
//  GroceryListTableViewController.swift
//  Menud
//
//  Created by Adson Pereira Leal on 30/01/18.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import Foundation

class GroceryViewTableController: UITableViewController, StoryboardLoadable {

    var categories: [IngredientCategory] = []

    lazy var presenter: GroceryListPresenter = GroceryListPresenter(view: self)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.onStart()
    }

    override func viewDidLoad() {
        self.tableView.tableFooterView = UIView()
        self.tableView.register(GroceryItemTableViewCell.self)
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories[section].groceryItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusable(forIndexPath: indexPath) as GroceryItemTableViewCell
        let category = categories[indexPath.section]
        cell.setupView(category.groceryItems[indexPath.row])
        cell.toggleAction = { item in
            item.categoryId = category.id
            self.presenter.onToggle(item: item)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section].name.uppercased()
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewHeaderFooterView()
        for view in (header.subviews) {
            view.removeFromSuperview()
        }
        let label = UILabel(frame: CGRect(x: 15, y: 5, width: tableView.frame.size.width, height: 38))
        label.text = categories[section].name.uppercased()
        label.textColor = .headerGray
        label.font = UIFont.systemFont(ofSize: 13)
        header.addSubview(label)
        header.bringSubview(toFront: label)
        return header

    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let category = categories[indexPath.section]
            let item = category.groceryItems[indexPath.row]
            item.categoryId = category.id
            self.presenter.onDelete(item: item)
        }
    }

}


extension GroceryViewTableController: GroceryListView {

    func reloadData() {
        categories = categories.filter({ $0.groceryItems.count > 0 })
        tableView.reloadData()
    }

    func setupCategories(_ categories: [IngredientCategory]) {
        self.categories = categories
        reloadData()
    }

    func update(_ category: IngredientCategory, for index: Int, scroll: Bool) {
        if let index = categories.index(where: {$0.id == category.id}) {
            self.categories[index] = category
            reloadData()
        }
    }

}
