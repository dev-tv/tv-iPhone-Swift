//
//  GroceryListRootPresenter.swift
//  MenuD
//
//  Created by Adson Pereira Leal on 31/01/18.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import Foundation

class GroceryListRootPresenter {
    
    let view: GroceryViewController
    
    init(view: GroceryViewController) {
        self.view = view
    }
    
    func onClearClick() {
        view.showConfirmClear()
    }
    
    func clearAll() {
        BackendUtilities.deleteGroceryList { success in
            if success {
                self.view.refresh()
               
            } else {
                self.view.showDeleteError()
            }
        }
    }
    
   func onExport(_ categories: [IngredientCategory]){
        let arrUncheckedItems = categories.flatMap {
            $0.groceryItems.filter { !$0.isChecked }
        }
        if arrUncheckedItems.count > 0 {
            let arrExportItems = arrUncheckedItems.map { $0.itemName }
            self.view.btnExport.isUserInteractionEnabled = true
            let reminders = RemindersCreator(arr: arrExportItems)
            reminders.exportItemsToRemindersApp()
        }
    }
}


