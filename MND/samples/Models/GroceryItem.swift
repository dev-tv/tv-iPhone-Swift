import Foundation


class GroceryItem {
    var ingredient: RecipeIngredient? = nil
    var isChecked: Bool = false
    var totalCount: String = ""
    var name: String? = nil
    var id: Int = -1
    var categoryId: Int = -1
    
    var itemName: String {
        get {
            return name ?? ingredient?.name ?? ""
        }
    }
    
    convenience init(name: String, count: String, categoryId: Int) {
        self.init()
        self.totalCount = count
        self.name = name
        self.categoryId = categoryId
    }
    
    convenience init(json: [String: Any]) {
        self.init()
        if let totalCount = json["count"] as? String {
            self.totalCount = totalCount
        }
        if let isChecked = json["isChecked"] as? Bool {
            self.isChecked = isChecked
        }
        self.name = json["name"] as? String
        if let ingredientJson = json["ingredient"] as? [String: Any] {
            self.ingredient = RecipeIngredient.init(json: ingredientJson)
        }
        if let id = json["id"] as? Int {
            self.id = id
        }
    }
    
    func asDict() -> [String: Any] {
        return [
            "count": totalCount,
            "name": name ?? "",
            "categoryId": categoryId,
            "isChecked": isChecked
        ]
    }

}
