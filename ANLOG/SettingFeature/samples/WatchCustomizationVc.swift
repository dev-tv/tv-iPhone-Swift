
import UIKit

class WatchCustomizationVc: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    //MARK:- Creating the IBOutlet of component....
    @IBOutlet weak var bgForWatchCustmization: UIImageView!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var viewBgSelectedBtn: UIView!
    @IBOutlet weak var btnForRim: UIButton!
    @IBOutlet weak var btnForDial: UIButton!
    @IBOutlet weak var btnForHands: UIButton!
    @IBOutlet weak var collViewForWatchCustomization: UICollectionView!
    @IBOutlet weak var imgViewForBack: UIImageView!
    @IBOutlet weak var lblForbarBottom: UILabel!
    @IBOutlet weak var titleForWatchCustomization: UILabel!
 
    var  selectedIndexPathDial : Int = 0
    var  selectedIndexPathRim : Int = 0
    var  selectedIndexPathHand : Int = 0
    var  collectionType: String = String()
    var  backToClassCheck : String = ""
    
    var realRimArr: NSMutableArray = NSMutableArray()
    var realDialArr: NSMutableArray = NSMutableArray()
    var handsImageOld: NSMutableArray = NSMutableArray()
    
    //MARK:- Application life cycle....
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpCustomNibCell()
        self.setUpCellFlowLayout()
        collectionType = "1"
       }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUpIndexWatchCustomization()
        self.setBackToRimDialHandsIndex()
        self.setBgAndNightTheme()
        self.updateBuyOwned()
    }
    
    //MARK:- Update Buy owned....
    func updateBuyOwned(){
        if collectionType == "1"{
            if UserDefaults.standard.value(forKey: "rims") != nil{
                let result : NSArray = UserDefaults.standard.value(forKey: "rims") as! NSArray
                dataCenterRimsArr = Rims.modelsFromDictionaryArray(array: result)
            }
        }else if collectionType == "2"{
            if UserDefaults.standard.value(forKey: "dials") != nil{
                let result : NSArray = UserDefaults.standard.value(forKey: "dials") as! NSArray
                dataCenterDialsArr = Dials.modelsFromDictionaryArray(array: result)
            }
        }else if collectionType == "3"{
            if UserDefaults.standard.value(forKey: "hands") != nil{
                let result : NSArray = UserDefaults.standard.value(forKey: "hands") as! NSArray
                dataCenterHandsArr = Hands.modelsFromDictionaryArray(array: result)
            }
        }else{
            print("No reload data")
        }
        collViewForWatchCustomization.reloadData()
    }
    
    //MARK:- set background night theme....
    func setBgAndNightTheme(){
        bgForWatchCustmization.image = UIImage(named:setBackGroundTheme)
        btnForRim.setTitleColor(textColorLbl.textColor, for: .normal)
        lblForbarBottom.backgroundColor = textColorLbl.textColor
        imgViewForBack.image = UIImage(named: back)
        titleForWatchCustomization.textColor = textColorLbl.textColor
    }
    
    //MARK:- setBackToRimDialHandsIndex....
    func setBackToRimDialHandsIndex(){
        if backToClassCheck == "fromRim"{
            collectionType = "1"
        }else if backToClassCheck == "fromDial"{
            collectionType = "2"
        }else if backToClassCheck == "fromHands"{
            collectionType = "3"
        }
        self.setInitialFont()
        collViewForWatchCustomization.reloadData()
    }
    
   //MARK:- setInitialFont....
    func setInitialFont(){
        if collectionType == "1"{
            btnForRim.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)
            btnForDial.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.thin)
            btnForHands.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.thin)
            btnForRim.backgroundColor = UIColor.clear
            btnForDial.backgroundColor = UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1.0)
            btnForHands.backgroundColor = UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1.0)
        }else if collectionType == "2"{
            btnForRim.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.thin)
            btnForDial.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)
            btnForHands.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.thin)
            btnForRim.backgroundColor = UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1.0)
            btnForDial.backgroundColor = UIColor.clear
            btnForHands.backgroundColor = UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1.0)
            
        }else if collectionType == "3"{
            btnForRim.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.thin)
            btnForDial.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.thin)
            btnForHands.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)
            btnForRim.backgroundColor = UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1.0)
            btnForDial.backgroundColor = UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1.0)
            btnForHands.backgroundColor = UIColor.clear
        }
    }
    
     //MARK:- setUpCustomNibCell....
    func setUpCustomNibCell(){
        collViewForWatchCustomization.delegate = self
        collViewForWatchCustomization.dataSource = self
        self.collViewForWatchCustomization.register(UINib(nibName: "WatchCustomizationCell", bundle: nil), forCellWithReuseIdentifier: "WatchCustomizationCell")
    }
    
 // #MARK: CollectionView cell spacing top left right and bottom side..
    func setUpCellFlowLayout(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 3, bottom: 3, right:3)
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width/2.0) - 6, height: (UIScreen.main.bounds.size.height/2.5))
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 4
        collViewForWatchCustomization!.collectionViewLayout = layout
    }
    
    //MARK:- setUpIndexWatchCustomization....
    func setUpIndexWatchCustomization(){
        if UserDefaults.standard.integer(forKey: "RimIndex") >= 0{
            let index = UserDefaults.standard.integer(forKey: "RimIndex")
            print(index)
            selectedIndexPathRim = index
        }
        if UserDefaults.standard.integer(forKey: "DialIndex") >= 0{
            let index = UserDefaults.standard.integer(forKey: "DialIndex")
            print(index)
            selectedIndexPathDial = index
        }
        if UserDefaults.standard.integer(forKey: "HandIndex") >= 0{
            let index = UserDefaults.standard.integer(forKey: "HandIndex")
            print(index)
            selectedIndexPathHand = index
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
     //MARK:- delgate and datasource of colletion view....
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionType == "1"{
            return dataCenterRimsArr.count
        }else if collectionType == "2"{
            return dataCenterDialsArr.count
        }else if (collectionType == "3"){
            return dataCenterHandsArr.count
        }else{
            print("No array found")
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : WatchCustomizationCell = collectionView.dequeueReusableCell(withReuseIdentifier: "WatchCustomizationCell", for: indexPath) as! WatchCustomizationCell
        cell.imgViewForSelectUnselect.isHidden = true
        var getValue : String = String()
        if collectionType == "1"{
            if UserDefaults.standard.integer(forKey: "RimIndex") >= 0{
                let index = UserDefaults.standard.integer(forKey: "RimIndex")
                if index == indexPath.item{
                    cell.imgViewForSelectUnselect.isHidden = false
                }
            }
            getValue = dataCenterRimsArr[indexPath.item].isOwned!
            cell.imgViewForItemImage.contentMode = .scaleAspectFit
            cell.imgViewForItemImage.clipsToBounds = true
            cell.imgViewForItemImage.image = UIImage(named:dataCenterRimsArr[indexPath.item].imageName!)
        }else if collectionType == "2"{
            if UserDefaults.standard.integer(forKey: "DialIndex") >= 0{
                let index = UserDefaults.standard.integer(forKey: "DialIndex")
                if index == indexPath.item{
                    cell.imgViewForSelectUnselect.isHidden = false
                }
            }
            getValue = dataCenterDialsArr[indexPath.item].isOwned!
            cell.imgViewForItemImage.contentMode = .scaleAspectFit
            cell.imgViewForItemImage.clipsToBounds = true
            cell.imgViewForItemImage.image = UIImage(named:dataCenterDialsArr[indexPath.item].imageName!)
        }else if (collectionType == "3"){
            if UserDefaults.standard.integer(forKey: "HandIndex") >= 0{
                let index = UserDefaults.standard.integer(forKey: "HandIndex")
                if index == indexPath.item{
                    cell.imgViewForSelectUnselect.isHidden = false
                }
            }
            getValue = dataCenterHandsArr[indexPath.item].isOwned!
            cell.imgViewForItemImage.contentMode = .center
            cell.imgViewForItemImage.clipsToBounds = true
            cell.imgViewForItemImage.image = UIImage(named:dataCenterHandsArr[indexPath.item].imageName!)
        }else{
          print("No cell")
        }
        switch getValue {
        case "0":
            cell.lblBuyOwned.text = "BUY"
            cell.lblBuyOwned.backgroundColor = UIColor.red
            cell.btnForBuyOwned.addTarget(self, action: #selector(WatchCustomizationVc.actionForBuy(_:)), for:.touchUpInside)
            cell.btnForBuyOwned.isUserInteractionEnabled = true
            cell.btnForImage.addTarget(self, action: #selector(WatchCustomizationVc.actionForImage(_:)), for:.touchUpInside)
        case "1":
            cell.lblBuyOwned.text = "OWNED"
            cell.lblBuyOwned.backgroundColor = UIColor(red: 50/255, green: 204/255, blue: 50/255, alpha: 1.0)
            cell.btnForImage.addTarget(self, action: #selector(WatchCustomizationVc.actionForImage(_:)), for:.touchUpInside)
            cell.btnForBuyOwned.isUserInteractionEnabled = false
        default:
            cell.lblBuyOwned.text  = "NO TEXT"
        }
        cell.btnForImage.tag = indexPath.item
        cell.btnForBuyOwned.tag = indexPath.item
        return cell
    }
    
    //MARK:- action on Buy....
    @objc func actionForBuy(_ sender : UIButton) {
        if collectionType == "1"{
            self.selectedIndexPathRim = sender.tag
            if UserDefaults.standard.value(forKey: "rims") != nil{
                let result : NSArray = UserDefaults.standard.value(forKey: "rims") as! NSArray
                dataCenterRimsArr = Rims.modelsFromDictionaryArray(array: result)
                dataCenterRimsArr[self.selectedIndexPathRim].isOwned! = "1"
                var array: [NSDictionary] = []
                for  i in dataCenterRimsArr{
                    array.append(i.dictionaryRepresentation().copy() as! NSDictionary)
                }
                UserDefaults.standard.set(array, forKey: "rims")
            }else{
                dataCenterRimsArr[self.selectedIndexPathRim].isOwned! = "1"
                var array: [NSDictionary] = []
                for  i in dataCenterRimsArr{
                    array.append(i.dictionaryRepresentation().copy() as! NSDictionary)
                }
                UserDefaults.standard.set(array, forKey: "rims")
            }
            
        }else if collectionType == "2"{
            self.selectedIndexPathDial = sender.tag
            if UserDefaults.standard.value(forKey: "dials") != nil{
                let result : NSArray = UserDefaults.standard.value(forKey: "dials") as! NSArray
                dataCenterDialsArr = Dials.modelsFromDictionaryArray(array: result)
                dataCenterDialsArr[self.selectedIndexPathDial].isOwned! = "1"
                var array: [NSDictionary] = []
                for  i in dataCenterDialsArr{
                    array.append(i.dictionaryRepresentation().copy() as! NSDictionary)
                }
                UserDefaults.standard.set(array, forKey: "dials")
            }else{
                dataCenterDialsArr[self.selectedIndexPathDial].isOwned! = "1"
                var array: [NSDictionary] = []
                for  i in dataCenterDialsArr{
                    array.append(i.dictionaryRepresentation().copy() as! NSDictionary)
                }
                UserDefaults.standard.set(array, forKey: "dials")
            }
        }else if collectionType == "3"{
            self.selectedIndexPathHand = sender.tag
            if UserDefaults.standard.value(forKey: "hands") != nil{
                let result : NSArray = UserDefaults.standard.value(forKey: "hands") as! NSArray
                dataCenterHandsArr = Hands.modelsFromDictionaryArray(array: result)
                dataCenterHandsArr[self.selectedIndexPathHand].isOwned! = "1"
                var array: [NSDictionary] = []
                for  i in dataCenterHandsArr{
                    array.append(i.dictionaryRepresentation().copy() as! NSDictionary)
                }
                UserDefaults.standard.set(array, forKey: "hands")
            }else{
                dataCenterHandsArr[self.selectedIndexPathHand].isOwned! = "1"
                var array: [NSDictionary] = []
                for  i in dataCenterHandsArr{
                    array.append(i.dictionaryRepresentation().copy() as! NSDictionary)
                }
                UserDefaults.standard.set(array, forKey: "hands")
            }
        }else{
            
        }
        self.updateBuyOwned()
    }
    
    //MARK:- action on image....
    @objc func actionForImage(_ sender : UIButton) {
          let selectVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectionVC") as! SelectionVC
        if collectionType == "1"{
            self.selectedIndexPathRim = sender.tag
            selectVC.indexForSelection = self.selectedIndexPathRim
            collectionType = "1"
        }else if collectionType == "2"{
            self.selectedIndexPathDial = sender.tag
            selectVC.indexForSelection = self.selectedIndexPathDial
            collectionType = "2"
        }else if collectionType == "3"{
            self.selectedIndexPathHand = sender.tag
            selectVC.indexForSelection = self.selectedIndexPathHand
            collectionType = "3"
        }else{
        }
        selectVC.collectionType = collectionType
        selectVC.classCheck = "WatchCustomizationVc"
       self.navigationController?.pushViewController(selectVC, animated: true)
    }
    
    @IBAction func actionForBackButton(_ sender: UIButton) {
      self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- action on button RIM....
    @IBAction func actionForBtnRim(_ sender: UIButton) {
        collectionType = "1"
        let tittleRIM = NSAttributedString(string: "RIM", attributes: [NSAttributedStringKey.foregroundColor: textColorLbl.textColor])
        btnForRim.setAttributedTitle(tittleRIM, for: .normal)
        btnForRim.backgroundColor = UIColor.clear
        btnForRim.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)
        
        let tittleDIAL = NSAttributedString(string: "DIAL", attributes: [NSAttributedStringKey.foregroundColor: UIColor.black])
        btnForDial.setAttributedTitle(tittleDIAL, for: .normal)
        btnForDial.backgroundColor = UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1.0)
        btnForDial.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.thin)
        
        let tittleHANDS = NSAttributedString(string: "HANDS", attributes: [NSAttributedStringKey.foregroundColor: UIColor.black])
        btnForHands.setAttributedTitle(tittleHANDS, for: .normal)
        btnForHands.backgroundColor = UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1.0)
        btnForHands.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.thin)
        updateBuyOwned()
    }
    
     //MARK:- action on button DIAL....
    @IBAction func actionForBtnDial(_ sender: UIButton) {
        collectionType = "2"
        let tittleRIM = NSAttributedString(string: "RIM", attributes: [NSAttributedStringKey.foregroundColor: UIColor.black])
        btnForRim.setAttributedTitle(tittleRIM, for: .normal)
        btnForRim.backgroundColor = UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1.0)
        btnForRim.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.thin)
        
        let tittleDIAL = NSAttributedString(string: "DIAL", attributes: [NSAttributedStringKey.foregroundColor: textColorLbl.textColor])
        btnForDial.setAttributedTitle(tittleDIAL, for: .normal)
        btnForDial.backgroundColor = UIColor.clear
        btnForDial.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)
        
        let tittleHANDS = NSAttributedString(string: "HANDS", attributes: [NSAttributedStringKey.foregroundColor: UIColor.black])
        btnForHands.setAttributedTitle(tittleHANDS, for: .normal)
        btnForHands.backgroundColor = UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1.0)
        btnForHands.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.thin)
        updateBuyOwned()
    }
    
     //MARK:- action on button HANDS....
    @IBAction func actionForBtnHands(_ sender: UIButton) {
        collectionType = "3"
        let tittleRIM = NSAttributedString(string: "RIM", attributes: [NSAttributedStringKey.foregroundColor: UIColor.black])
        btnForRim.setAttributedTitle(tittleRIM, for: .normal)
        btnForRim.backgroundColor = UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1.0)
        btnForRim.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.thin)
        
        let tittleDIAL = NSAttributedString(string: "DIAL", attributes: [NSAttributedStringKey.foregroundColor: UIColor.black])
        btnForDial.setAttributedTitle(tittleDIAL, for: .normal)
        btnForDial.backgroundColor = UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1.0)
        btnForDial.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.thin)
        
        let tittleHANDS = NSAttributedString(string: "HANDS", attributes: [NSAttributedStringKey.foregroundColor: textColorLbl.textColor])
        btnForHands.setAttributedTitle(tittleHANDS, for: .normal)
        btnForHands.backgroundColor = UIColor.clear
        btnForHands.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)
        updateBuyOwned()
    }
}
