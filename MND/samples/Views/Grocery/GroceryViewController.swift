import Foundation

class GroceryViewController: UIViewController, StoryboardLoadable {
    
    @IBOutlet weak var groceryList: UIView!
    @IBOutlet weak var groceryAisles: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var btnExport: UIButton!
    
    var groceryListViewController: GroceryListViewController? = nil
    var groceryAislesViewController: GroceryViewTableController? = nil
    lazy var presenter = GroceryListRootPresenter(view: self)
    
    var isAisles: Bool {
        get {
            return segmentedControl.selectedSegmentIndex == 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.segmentedControl.setCustomFont(name:Constant.FontFamily.SF_UI_Text, size: Constant.regularFontSize)
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishExporting(_:)), name: NSNotification.Name(rawValue: Constant.kDidFinishExportingToReminders), object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func didFinishExporting(_ notification: Notification) {
        btnExport.isUserInteractionEnabled = true
    }
    
    @IBAction func onTabChange(_ sender: Any) {
        groceryList.isHidden = isAisles
        groceryAisles.isHidden = !isAisles
    }
    
    @IBAction func onClear(_ sender: Any) {
        presenter.onClearClick()
    }
    
    @IBAction func onExport(_ sender: Any) {
        let categories = (isAisles ? groceryListViewController?.categories : groceryAislesViewController?.categories) ?? []
        presenter.onExport(categories)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "AisleSegue":
                groceryListViewController = segue.destination as? GroceryListViewController
            case "TableSegue":
                groceryAislesViewController = segue.destination as? GroceryViewTableController
            default:
                return
            }
        }
    }
    
    func showConfirmClear() {
        let alert = UIAlertController(title: "grocery_clear_alert_title".localized(), message: "grocery_clear_alert_message".localized(), preferredStyle: .alert)
        let clearAction = UIAlertAction(title: "grocery_clear_alert_clear".localized(), style: .destructive) { (alert: UIAlertAction!) -> Void in
            self.presenter.clearAll()
        }
        let cancelAction = UIAlertAction(title: "grocery_clear_alert_cancel".localized(), style: .default)
        
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion:nil)
    }
    
    func refresh() {
        let presenters = [groceryListViewController?.presenter, groceryAislesViewController?.presenter]
        presenters.forEach { $0?.onStart() }
    }
    
    func showDeleteError() {
        let alert = UIAlertController(title: "grocery_clear_alert_failure".localized(), message: "grocery_clear_alert_failure_message".localized(), preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "grocery_clear_alert_ok".localized(), style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
