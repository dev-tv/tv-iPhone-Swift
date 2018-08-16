import Foundation
import TGLStackedViewController

protocol GroceryListView {
    func setupCategories(_ categories: [IngredientCategory])
    func update(_ category: IngredientCategory, for index: Int, scroll: Bool)
}

class GroceryListViewController: TGLStackedViewController, StoryboardLoadable, GroceryListView {
    
    let cellSize: CGFloat = 57
    let bottomSpace: CGFloat = 70
    
    var categories: [IngredientCategory] = []
    
    lazy var presenter: GroceryListPresenter = GroceryListPresenter(view: self)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.onStart()
    }
    
    override func viewDidLoad() {
        collectionView?.register(GroceryCategoryCollectionViewCell.self)
        collectionView?.setCollectionViewLayout(stackedLayout, animated: false)
        unexposedItemsAreSelectable = true
        
        stackedLayout.topReveal = cellSize
        exposedBottomOverlap = -10
        exposedLayoutMargin = UIEdgeInsetsMake(8.0, -10.0, 0.0, -10.0)
        stackedLayout.layoutMargin = exposedLayoutMargin
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusable(forIndexPath: indexPath) as GroceryCategoryCollectionViewCell
        cell.category = categories[indexPath.row]
        cell.whenEdit {
            self.exposedItemIndexPath = indexPath
        }
        cell.onCreate {
            self.presenter.onCreate(item: $0)
        }
        cell.onDelete {
            self.presenter.onDelete(item: $0)
        }
        cell.onToggle {
            self.presenter.onToggle(item: $0)
        }
        return cell
    }
    
    func setupCategories(_ categories: [IngredientCategory]) {
        self.categories = categories
        collectionView?.reloadData()
    }
    
    func update(_ category: IngredientCategory, for index: Int, scroll: Bool) {
        let cell = collectionView?.cellForItem(at: IndexPath(row: index, section: 0)) as? GroceryCategoryCollectionViewCell
        cell?.category = category
        if scroll {
            cell?.scrollToMax()
        }
    }
    
}
