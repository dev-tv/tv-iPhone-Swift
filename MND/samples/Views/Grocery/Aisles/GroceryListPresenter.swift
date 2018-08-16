import Foundation


let ingredient = RecipeIngredient(name: "Ingredient to test")


class GroceryListPresenter {
    
    let view: GroceryListView
    var categories: [IngredientCategory] = []
    
    init(view: GroceryListView) {
        self.view = view
    }
    
    func onStart() {
        BackendUtilities.getGroceryList( { categories in
            if let categories = categories {
                self.categories = categories
                self.view.setupCategories(categories)
            }
        })
    }
    
    func onCreate(item: GroceryItem) {
        optmisticAddItem(item)
        BackendUtilities.createGroceryItem(item, { createdItem in
            if createdItem == nil {
                self.onStart()
            }
        })
    }
    
    func onToggle(item: GroceryItem) {
        item.isChecked = !item.isChecked
        optmisticChangeItem(item)
        BackendUtilities.updateGroceryItem(item, { createdItem in
            if createdItem == nil {
                self.onStart()
            }
        })
    }

    func onDelete(item: GroceryItem) {
        optmisticDeleteItem(item)
        BackendUtilities.deleteGroceryItem(item, { success in
            if !success {
                self.onStart()
            }
        })
    }
    
    private func optmisticAddItem(_ item: GroceryItem) {
        if let items = findItems(for: item.categoryId) {
            set((items + [item]), for: item.categoryId)
            refresh(item.categoryId, scroll: true)
        }
    }
    
    private func optmisticChangeItem(_ item: GroceryItem) {
        if let items = findItems(for: item.categoryId) {
            set(items.map({ $0.id == item.id ? item : $0}), for: item.categoryId)
            refresh(item.categoryId)
        }
    }
    
    private func findItems(for categoryId: Int) -> [GroceryItem]? {
        return categories.first(where: {$0.id == categoryId})?.groceryItems
    }
    
    private func set(_ items: [GroceryItem], for categoryId: Int) {
        categories.first(where: {$0.id == categoryId})?.groceryItems = items
    }
    
    private func refresh(_ categoryId: Int, scroll: Bool = false) {
        if let index = categories.index(where: {$0.id == categoryId}) {
            self.view.update(categories[index], for: index, scroll: scroll)
        }
    }
    
    private func optmisticDeleteItem(_ item: GroceryItem) {
        if let items = findItems(for: item.categoryId)?.filter({ $0.id != item.id}) {
            set(items, for: item.categoryId)
            refresh(item.categoryId)
        }
    }
}
