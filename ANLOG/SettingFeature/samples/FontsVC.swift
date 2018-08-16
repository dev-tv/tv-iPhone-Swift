
import UIKit

protocol switchViewControllerProtocol {
    func goToViewController(pushData1: String,pushData2: UserEvent)
}

protocol switchViewControllerProtocolForHome {
    func goToViewControllerForHome(pushData1: String,pushData2: UserEvent?)
}


class FontsVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    //MARK:- Creating IBOutlet of component ....
    @IBOutlet weak var imgViewForSelection: UIImageView!
    @IBOutlet weak var bgForFonts: UIImageView!
    @IBOutlet weak var titleForFonts: UILabel!
    @IBOutlet weak var imgViewForBack: UIImageView!
    @IBOutlet weak var lblForNavigationBarBottomLine: UILabel!
    
    var  selectedIndexPath : Int = 0
    var selectedIndexForCreateEvent : Int = 0
    var selectedIndexForColor : Int = 0
    
    var fontsImageArr: [String] = ["font1","font2","font3","font4","font5","font6","font7","font8","font9"]
    var startEventTime : String = ""
    var endEventTime : String = ""
    
    @IBOutlet weak var collectViewForFonts: UICollectionView!
    var getStrFromCallBack: String = ""
    var strIsCommingFrom: String = ""
    var Event: UserEvent?
    var switchDelegate: switchViewControllerProtocol?
    var switchDelegateHome: switchViewControllerProtocolForHome?
    
   
    //MARK:- Application life cycle ....
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpCustomNibCell()
        self.cellFlowLayOut()
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(true)
        self.setBgAndNightTheme()
        self.updateBuyOwned()
        print(strIsCommingFrom)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- update for Fonts from userdefaults ....
    func updateBuyOwned(){
        if UserDefaults.standard.value(forKey: "fonts") != nil{
            let result : NSArray = UserDefaults.standard.value(forKey: "fonts") as! NSArray
            dataCenterFontsArr = Fonts.modelsFromDictionaryArray(array: result)
        }
        collectViewForFonts.reloadData()
    }
    
    //MARK:- set backgroung according black theme ....
    func setBgAndNightTheme(){
        bgForFonts.image = UIImage(named:setBackGroundTheme)
        titleForFonts.textColor = textColorLbl.textColor
        imgViewForBack.image = UIImage(named:back)
        lblForNavigationBarBottomLine.backgroundColor = textColorLbl.textColor
    }
    
    //MARK:-setUp for Custom colletion cell ....
    func setUpCustomNibCell(){
        collectViewForFonts.delegate = self
        collectViewForFonts.dataSource = self
        self.collectViewForFonts.register(UINib(nibName: "FontCell", bundle: nil), forCellWithReuseIdentifier: "FontCell")
    }
    
     // #MARK: CollectionView cell spacing top left right and bottom side..
    func cellFlowLayOut(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 3, bottom: 2, right:3)
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width/2.0) - 6, height: (UIScreen.main.bounds.size.height/2.5))
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 4
        collectViewForFonts!.collectionViewLayout = layout
    }

    //MARK:- delegate and data source of collection view ....
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataCenterFontsArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : FontCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FontCell", for: indexPath) as! FontCell
        cell.imgViewForSelectUnselect.isHidden = true
        let getValue : String = dataCenterFontsArr[indexPath.item].isOwned!
        switch getValue {
        case "0":
            cell.lblForBuyOwned.text = "BUY"
            cell.imgViewForSelectUnselect.isHidden = true
            cell.lblForBuyOwned.backgroundColor = UIColor.red
            cell.btnForBuyOwned.addTarget(self, action: #selector(FontsVC.actionForBuyOwned(_:)), for:.touchUpInside)
            cell.btnForImageView.addTarget(self, action: #selector(FontsVC.actionForImage(_:)), for:.touchUpInside)
        case "1":
            cell.lblForBuyOwned.text = "OWNED"
            cell.lblForBuyOwned.backgroundColor = UIColor(red: 50/255, green: 204/255, blue: 50/255, alpha: 1.0)
            cell.btnForImageView.addTarget(self, action: #selector(FontsVC.actionForImage(_:)), for:.touchUpInside)
        default:
            cell.lblForBuyOwned.text  = "NO TEXT"
        }
        if UserDefaults.standard.integer(forKey: "fontIndex") >= 0{
            let index = UserDefaults.standard.integer(forKey: "fontIndex")
            if index == indexPath.item{
                cell.imgViewForSelectUnselect.isHidden = true
            }
        }
        cell.lblForFontName.text = dataCenterFontsArr[indexPath.item].fontsName
        cell.btnForBuyOwned.tag = indexPath.row
        cell.btnForImageView.tag = indexPath.item
        cell.imgViewForItemImage.image = UIImage(named:fontsImageArr[indexPath.item])
        return cell
    }
  
    //MARK:- action on image ....
     @objc func actionForImage(_ sender : UIButton) {
        let selectVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectionVC") as! SelectionVC
        self.selectedIndexPath = sender.tag
        selectVC.classCheck = "FontsVC"
        selectVC.indexForSelection = self.selectedIndexPath
        selectVC.getStrFromCallBack = getStrFromCallBack
         self.present(selectVC, animated: true, completion: nil)
    }
    
    //MARK:- action on label text ....
     @objc func actionForBuyOwned(_ sender : UIButton) {
        self.selectedIndexPath = sender.tag
        if UserDefaults.standard.value(forKey: "fonts") != nil{
            let result : NSArray = UserDefaults.standard.value(forKey: "fonts") as! NSArray
            dataCenterFontsArr = Fonts.modelsFromDictionaryArray(array: result)
            dataCenterFontsArr[self.selectedIndexPath].isOwned! = "1"
            var array: [NSDictionary] = []
            for  i in dataCenterFontsArr{
                array.append(i.dictionaryRepresentation().copy() as! NSDictionary)
            }
            UserDefaults.standard.set(array, forKey: "fonts")
        }else{
            dataCenterFontsArr[self.selectedIndexPath].isOwned! = "1"
            var array: [NSDictionary] = []
            for  i in dataCenterFontsArr{
                array.append(i.dictionaryRepresentation().copy() as! NSDictionary)
            }
            UserDefaults.standard.set(array, forKey: "fonts")
        }
        self.updateBuyOwned()
    }
    
    //MARK:- action on back button ....
    @IBAction func actionForBackButton(_ sender: UIButton) {
        if getStrFromCallBack == "fromCreateEvent"{
            getStrFromCallBack = "fromCreateEvent"
            
            
            self.switchDelegateHome?.goToViewControllerForHome(pushData1: getStrFromCallBack, pushData2: Event)
            self.dismiss(animated: true, completion: nil)
        }else if getStrFromCallBack == "fromUpdateEvent"{
            getStrFromCallBack = "fromUpdateEvent"
            self.switchDelegate?.goToViewController(pushData1: getStrFromCallBack, pushData2: Event!)
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
}
