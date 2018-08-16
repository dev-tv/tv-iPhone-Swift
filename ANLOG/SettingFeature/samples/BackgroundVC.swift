
import UIKit

class BackgroundVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    //MARK:- Creating the IBOutlet of componet ....
    @IBOutlet weak var bgForBackground: UIImageView!
    @IBOutlet weak var titleForBackground: UILabel!
    var OldBackgroundImage: NSMutableArray = NSMutableArray()
    @IBOutlet weak var collectViewForBackGround: UICollectionView!
    var classCheck : String = ""
    @IBOutlet weak var imgViewForBack: UIImageView!
    @IBOutlet weak var lblForNavigationBottom: UILabel!
    
    //MARK:- Application life cycle ....
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomNibCell()
        self.setUpCellFlowLayOut()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.integer(forKey: "index") >= 0{
        let index = UserDefaults.standard.integer(forKey: "index")
        selectedIndexPath = index
        collectViewForBackGround.reloadData()
        }
        self.setBgAndNightTheme()
        self.updateBuyOwned()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- update background data
    func updateBuyOwned(){
        if UserDefaults.standard.value(forKey: "background") != nil{
            let result : NSArray = UserDefaults.standard.value(forKey: "background") as! NSArray
            dataCenterBgArr = Background.modelsFromDictionaryArray(array: result)
            collectViewForBackGround.reloadData()
        }
    }
    
    //MARK:- set background theme....
    func setBgAndNightTheme(){
        bgForBackground.image = UIImage(named:setBackGroundTheme)
        titleForBackground.textColor = textColorLbl.textColor
        lblForNavigationBottom.backgroundColor = textColorLbl.textColor
        imgViewForBack.image = UIImage(named:back)
    }
    
    //MARK:- set custom cell ....
    func setCustomNibCell(){
        collectViewForBackGround.delegate = self
        collectViewForBackGround.dataSource = self
        self.collectViewForBackGround.register(UINib(nibName: "BackgroundCell", bundle: nil), forCellWithReuseIdentifier: "BackgroundCell")
    }
   
     // #MARK: CollectionView cell spacing top left right and bottom side..
    func setUpCellFlowLayOut(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 3, bottom: 0, right:3)
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width/2.0) - 6, height: (UIScreen.main.bounds.size.height/2.5))
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 4
        collectViewForBackGround!.collectionViewLayout = layout
    }
    
    //MARK:- setup for delegate and datasource of colletion view ....
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataCenterBgArr.count
    }
    
    var  selectedIndexPath : Int = 0
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : BackgroundCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BackgroundCell", for: indexPath) as! BackgroundCell
        cell.imgViewForSelectUnselect.isHidden = true
        let getValue : String = dataCenterBgArr[indexPath.item].isOwned!
        switch getValue {
        case "0":
            cell.lblBuyOwned.text = "BUY"
            cell.imgViewForSelectUnselect.isHidden = true
            cell.lblBuyOwned.backgroundColor = UIColor.red
            cell.btnForBuyOwned.addTarget(self, action: #selector(BackgroundVC.actionForBuy(_:)), for:.touchUpInside)
            cell.btnForImage.addTarget(self, action: #selector(BackgroundVC.actionForImage(_:)), for:.touchUpInside)
            cell.btnForBuyOwned.isUserInteractionEnabled = true
        case "1":
            cell.lblBuyOwned.text = "OWNED"
            cell.lblBuyOwned.backgroundColor = UIColor(red: 50/255, green: 204/255, blue: 50/255, alpha: 1.0)
            cell.btnForImage.addTarget(self, action: #selector(BackgroundVC.actionForImage(_:)), for:.touchUpInside)
             cell.btnForBuyOwned.isUserInteractionEnabled = false
        default:
            cell.lblBuyOwned.text  = "NO TEXT"
        }
        if UserDefaults.standard.integer(forKey: "index") >= 0{
            let index = UserDefaults.standard.integer(forKey: "index")
            if index == indexPath.item{
                cell.imgViewForSelectUnselect.isHidden = false
            }
        }
        cell.btnForBuyOwned.tag = indexPath.row
        cell.btnForImage.tag = indexPath.item
        cell.imgViewForItemImage.image = UIImage(named:dataCenterBgArr[indexPath.item].imageName!)
        return cell
    }

    //MARK:- action on buy ....
    @objc func actionForBuy(_ sender : UIButton) {
        self.selectedIndexPath = sender.tag
        if UserDefaults.standard.value(forKey: "background") != nil{
            let result : NSArray = UserDefaults.standard.value(forKey: "background") as! NSArray
            dataCenterBgArr = Background.modelsFromDictionaryArray(array: result)
            dataCenterBgArr[self.selectedIndexPath].isOwned! = "1"
            var array: [NSDictionary] = []
            for  i in dataCenterBgArr{
                array.append(i.dictionaryRepresentation().copy() as! NSDictionary)
            }
            UserDefaults.standard.set(array, forKey: "background")
        }else{
            dataCenterBgArr[self.selectedIndexPath].isOwned! = "1"
            var array: [NSDictionary] = []
            for  i in dataCenterBgArr{
                array.append(i.dictionaryRepresentation().copy() as! NSDictionary)
            }
            UserDefaults.standard.set(array, forKey: "background")
        }
        self.updateBuyOwned()
    }
    
    //MARK:- action on image ....
    @objc func actionForImage(_ sender : UIButton) {
        self.selectedIndexPath = sender.tag
        let selectVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectionVC") as! SelectionVC
        selectVC.indexForSelection = self.selectedIndexPath
        selectVC.classCheck = "BackgroundVC"
        //self.present(selectVC, animated: true, completion: nil)
        self.navigationController?.pushViewController(selectVC, animated: true)
    }
    
    @IBAction func actionForBackButton(_ sender: UIButton) {
    self.navigationController?.popViewController(animated: true)
    }
}
