//
//  EditFilterVc.swift
//  Prowler
//
//  Created by dev5 on 2/23/18.
//  Copyright © 2018 dev. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import RangeSeekSlider
import Alamofire

class EditFilterVc: UIViewController,UIActionSheetDelegate {
    
    @IBOutlet var lblCogDisable: UILabel!
    @IBOutlet var nsLayoutSdrYelo: NSLayoutConstraint!
    // @IBOutlet
    @IBOutlet weak var btnForSubmitButton: UIButton!//NexaBold 20.0
   // @IBOutlet fileprivate weak var rangeSliderCustom: RangeSeekSlider!
    @IBOutlet weak var btnForResetButton: UIButton!//NexaBold 20.0
   
    @IBOutlet var slidCogGray: HDoubleBarSliderView!
    var intvwFullHeight : CGFloat = 750
    var intDefaultValue : CGFloat = 750
    @IBOutlet var nsLayoutBottomLbl: NSLayoutConstraint!
    @IBOutlet var nsLayoutSightHeight: NSLayoutConstraint!
    @IBOutlet var nsLayoutVerifiSigh: NSLayoutConstraint!
    @IBOutlet var nsLayoutLblbgGray: NSLayoutConstraint!
    @IBOutlet weak var tblFilter: UITableView!
    @IBOutlet weak var btnAll: UIButton!
    @IBOutlet weak var btnMonth: UIButton!
    @IBOutlet weak var btnWeek: UIButton!
    @IBOutlet weak var btnToday: UIButton!
    @IBOutlet weak var vWCoSiNsLayout: NSLayoutConstraint!
    @IBOutlet weak var vwCoSi: UIView!
    @IBOutlet weak var vwFullFilter: UIView!
    @IBOutlet weak var btnCoSiHideSo: UIButton!
    @IBOutlet weak var btnSiSNVS: UIButton!
    @IBOutlet weak var btnSiSVS: UIButton!
    @IBOutlet weak var lblDisableSight: UILabel!
    @IBOutlet weak var lblbgGray: UILabel!
    @IBOutlet weak var btnTotalSi: UIButton!
    @IBOutlet weak var btnRepuShowAl: UIButton!
    @IBOutlet weak var btnCouSNVCS: UIButton!
    @IBOutlet weak var btnCSiSOC: UIButton!
    @IBOutlet weak var btnSighShowAl: UIButton!
    @IBOutlet weak var btnCogSighShowAl: UIButton!
    @IBOutlet weak var reputabilitySlide: HDoubleBarSliderView!
    @IBOutlet weak var sliderForSight: HDoubleBarSliderView!
    @IBOutlet weak var sliderForCougar: HDoubleBarSliderView!
    @IBOutlet weak var sliderYelowSignt: HDoubleBarSliderView!
    @IBOutlet weak var sliderGraySignt: HDoubleBarSliderView!
    var blCougerHeight = true
    var blSightSVS:Bool = false
    var blSightSNVS:Bool = false
    lazy var presenter = EditFilterPresenter(view: self)
    var blCheckEdit = false
    var strValueDate = String()
    var numReputability = CGFloat()
    // { "isNVS" : true/false, "NVSrating" : number, "isVS" : true/false, "VSrating" : number },
     var blIsNvs = Bool()
     var blisVS = Bool()
     var numNVSrating = CGFloat()
     var numVSrating = CGFloat()
    // {"type" : "ALL"/"NVS", "rating" : number},
    var strCougStatus = String()
    var numCougarSightings = CGFloat()
    var numTotalSightings = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnTotalSi.layer.cornerRadius = 5
        btnTotalSi.layer.borderColor = UIColor.purple.cgColor
        btnTotalSi.layer.borderWidth = 1
        btnForSubmitButton.layer.cornerRadius = 19
        btnForResetButton.layer.cornerRadius = 19
        btnToday.isSelected = false
        sliderGraySignt.isUserInteractionEnabled = false
        btnRepuShowAl.layer.borderColor = UIColor.black.cgColor
        btnRepuShowAl.layer.borderWidth = 1
        btnSighShowAl.layer.borderColor = UIColor.black.cgColor
        btnSighShowAl.layer.borderWidth = 1
        btnCogSighShowAl.layer.borderColor = UIColor.black.cgColor
        btnCogSighShowAl.layer.borderWidth = 1
        btnRepuShowAl.layer.cornerRadius = 5
        btnSighShowAl.layer.cornerRadius = 5
        btnCogSighShowAl.layer.cornerRadius = 5
        btnSiSVS.isSelected = false
        slidCogGray.isUserInteractionEnabled = false
        reputabilitySlide.isUserInteractionEnabled = true
        sliderForCougar.isHidden = true
        slidCogGray.isHidden = false
        if UserDefaults.standard.value(forKey: "filterData") != nil{
        var prmLocal:Parameters = UserDefaults.standard.value(forKey: "filterData") as! Parameters
        /*
             "reputability" : self.view.numReputability,
             "type" : "TODAY",
             "sightings" : ["isNVS":self.view.blSightSNVS, "NVSrating" : self.view.numNVSrating, "isVS" : self.view.blSightSVS, "VSrating" : self.view.numVSrating],
             "cougarSightings" : ["type" : self.view.strCougStatus, "rating" : self.view.sliderForCougar],
             "totalSightings" : self.view.numTotalSightings
        */
            print(prmLocal)
            blCougerHeight = true
            var filterary = prmLocal["filter"]as! [String:Any]
            numReputability = filterary["reputability"] as! CGFloat
            strValueDate = filterary["type"] as! String
            numTotalSightings = filterary["totalSightings"] as! Int
            var sightcheck = filterary["sightings"]as! [String:Any]
            blSightSNVS = sightcheck["isNVS"] as! Bool
            numNVSrating = sightcheck["NVSrating"] as! CGFloat
            blSightSVS = sightcheck["isVS"] as! Bool
            numVSrating = sightcheck["VSrating"] as! CGFloat
            var cogPram = filterary["cougarSightings"]as! [String:Any]
            strCougStatus = cogPram["type"] as! String
            numCougarSightings = cogPram["rating"] as! CGFloat
          
           if numTotalSightings == 10{
            intSheet = 1
             self.btnTotalSi.setTitle("10", for: .normal)
           }else if numTotalSightings == 20{
            intSheet = 1
             self.btnTotalSi.setTitle("20", for: .normal)
           }else if numTotalSightings == 30{
            intSheet = 2
             self.btnTotalSi.setTitle("30", for: .normal)
           }else if numTotalSightings == 40{
            intSheet = 3
             self.btnTotalSi.setTitle("30", for: .normal)
           }else if numTotalSightings == 50{
            intSheet = 4
            self.btnTotalSi.setTitle("50", for: .normal)
           }
            
            if strValueDate == "TODAY"{
                btnToday.isSelected = true
                btnWeek.isSelected = false
                btnMonth.isSelected = false
                btnAll.isSelected = false
            }else if strValueDate == "WEEK"{
                btnToday.isSelected = false
                btnWeek.isSelected = true
                btnMonth.isSelected = false
                btnAll.isSelected = false
            }else if strValueDate == "MONTH"{
                btnToday.isSelected = false
                btnWeek.isSelected = false
                btnMonth.isSelected = true
                btnAll.isSelected = false
            }else if strValueDate == "alldata"{
                btnToday.isSelected = false
                btnWeek.isSelected = false
                btnMonth.isSelected = false
                btnAll.isSelected = true
            }//. .
            
            if blSightSNVS == true && blSightSVS == false{
                blSightSNVS = true
                btnSiSNVS.isSelected = true
                sliderGraySignt.isHidden = true
                sliderForSight.isHidden = true
                sliderYelowSignt.isHidden = false
                nsLayoutLblbgGray.constant = 45
                nsLayoutVerifiSigh.constant = -100
                nsLayoutSdrYelo.constant = 48
                nsLayoutSightHeight.constant = 110 + 38 + 10 + 38
               // intvwFullHeight = intvwFullHeight
                vwFullFilter.frame.size.height = intvwFullHeight
                print("intvwFullHeight:\(intvwFullHeight)")
                tblFilter.reloadData()
            }else if blSightSNVS == false && blSightSVS == true{
                btnSiSVS.isSelected = true
                blSightSVS = true
                sliderGraySignt.isHidden = true
                nsLayoutLblbgGray.constant = 0
                nsLayoutVerifiSigh.constant = 5
                sliderForSight.isHidden = false
                sliderYelowSignt.isHidden = true
                nsLayoutSightHeight.constant = 110 + 38 + 10 + 38
               // intvwFullHeight = intvwFullHeight
                vwFullFilter.frame.size.height = intvwFullHeight
                print("intvwFullHeight:\(intvwFullHeight)")
                tblFilter.reloadData()
            }else if blSightSNVS == true && blSightSVS == true{
                btnSiSVS.isSelected = true
                btnSiSNVS.isSelected = true
                blSightSVS = true
                sliderGraySignt.isHidden = true
                bothSelected()
            }else if blSightSNVS == false && blSightSVS == false{
                blSightSVS = false
                btnSiSVS.isSelected = false
                btnSiSNVS.isSelected = false
                lblDisableSight.isHidden = true
                nsLayoutLblbgGray.constant = 0
                sliderForSight.isHidden = true
                nsLayoutSightHeight.constant = 110 + 38 + 10 + 38
                SightingOff()
            }
            
           if strCougStatus == "ALL"{
            sliderForCougar.isHidden = false
            slidCogGray.isHidden = true
            btnCouSNVCS.isSelected =  false
            btnCSiSOC.isSelected = true
            cogSlideShow()
            }else if strCougStatus == "NVS"{
            sliderForCougar.isHidden = false
            slidCogGray.isHidden = true
            btnCouSNVCS.isSelected =  true
            btnCSiSOC.isSelected = false
            cogSlideShow()
           }else{
            sliderForCougar.isHidden = true
            slidCogGray.isHidden = false
            btnCouSNVCS.isSelected =  false
            btnCSiSOC.isSelected = false
            coglideHide()
            }
        
        }else{
            self.resetFilter()
            coglideHide()
            intvwFullHeight = intDefaultValue
            vwFullFilter.frame.size.height = intvwFullHeight
            print("intvwFullHeight:\(intvwFullHeight)")
            tblFilter.reloadData()
        }
       
        UserDefaults.standard.synchronize()
        
       
        // Do any additional setup after loading the view.
    }
    
    private func setup() {
 
        vwCoSi.isHidden = true
        btnCoSiHideSo.isSelected = false
        vWCoSiNsLayout.constant = 5
        tblFilter.reloadData()

    }
    
    //MARK: Custom Methods
    
    func FontSetup(){
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
         //btnCoSiHideSo.isSelected = true
       // FontSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        sliderForCougar.InitialSetup(sliderType: 1, hasBottomLeftBtn: true,  devicWidth: self.view.frame.width, scaleType: 1)
       
        reputabilitySlide.InitialSetup(sliderType: 2, hasBottomLeftBtn: true,  devicWidth: self.view.frame.width, scaleType: 3)
        
        sliderForSight.InitialSetup(sliderType: 2, hasBottomLeftBtn: true,  devicWidth: self.view.frame.width, scaleType: 1)
        
        sliderYelowSignt.InitialSetup(sliderType: 5, hasBottomLeftBtn: true,  devicWidth: self.view.frame.width, scaleType: 1)
        
        sliderGraySignt.InitialSetup(sliderType: 6, hasBottomLeftBtn: true,  devicWidth: self.view.frame.width, scaleType: 1)
        
        slidCogGray.InitialSetup(sliderType: 6, hasBottomLeftBtn: true,  devicWidth: self.view.frame.width, scaleType: 1)
        
        if UserDefaults.standard.value(forKey: "filterData") != nil{
            sliderForCougar.setValueOfSlider(postition: numCougarSightings)
            reputabilitySlide.setValueOfSlider(postition: numReputability/10.0)
            sliderForSight.setValueOfSlider(postition: numVSrating)
            sliderYelowSignt.setValueOfSlider(postition: numNVSrating)
            sliderGraySignt.setValueOfSlider(postition: 0.0)
            slidCogGray.setValueOfSlider(postition: 0.0)
            
        }else{
            sliderSetNull()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sliderSetNull(){
        sliderForCougar.setValueOfSlider(postition: 0.0)
        reputabilitySlide.setValueOfSlider(postition: 0.0)
        sliderForSight.setValueOfSlider(postition: 0.0)
        sliderYelowSignt.setValueOfSlider(postition: 0.0)
        sliderGraySignt.setValueOfSlider(postition: 0.0)
        slidCogGray.setValueOfSlider(postition: 0.0)
    }
    
    //Action Method
    //"TODAY"/"WEEK"/"MONTH",
    @IBAction func actionToday(_ sender: Any) {
        blCheckEdit = true
        btnToday.isSelected = true
        btnWeek.isSelected = false
        btnMonth.isSelected = false
        btnAll.isSelected = false
        strValueDate = "TODAY"
    }
    
    @IBAction func actionWeek(_ sender: Any) {
        blCheckEdit = true
        btnToday.isSelected = false
        btnWeek.isSelected = true
        btnMonth.isSelected = false
        btnAll.isSelected = false
        strValueDate = "WEEK"
    }
    
    @IBAction func actionMonth(_ sender: Any) {
        blCheckEdit = true
        btnToday.isSelected = false
        btnWeek.isSelected = false
        btnMonth.isSelected = true
        btnAll.isSelected = false
         strValueDate = "MONTH"
    }
    
    @IBAction func actionAll(_ sender: Any) {
        
        blCheckEdit = true
        btnToday.isSelected = false
        btnWeek.isSelected = false
        btnMonth.isSelected = false
        btnAll.isSelected = true
        strValueDate = "alldata"
    }
    
    @IBAction func ActionOnBack(_ sender: Any) {

       let refreshAlert = UIAlertController(title:"Message" , message: NSLocalizedString("save_filter_change", comment: ""), preferredStyle: UIAlertControllerStyle.alert)

        refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: { (action: UIAlertAction!) in
            self.navigationController?.popViewController(animated: true)
        }))

        refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action: UIAlertAction!) in
            //print("Handle Cancel Logic here")
        }))
        present(refreshAlert, animated: true, completion: nil)
    
    }
    
    @IBAction func actionReset(_ sender: Any) {
        
        let refreshAlert = UIAlertController(title: NSLocalizedString("Are you sure!", comment: ""), message: "Want to discard all changes", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .default, handler: { (action: UIAlertAction!) in
           
            self.coglideHide()
            self.resetFilter()
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .cancel, handler: { (action: UIAlertAction!) in
            //print("Handle Cancel Logic here")
        }))
        present(refreshAlert, animated: true, completion: nil)
        
    }
    
    func backCheck(){
        
        print("numCougarSightings:\(numCougarSightings)==\(CGFloat(self.sliderForCougar.sliderValue))////numVSrating:\(numVSrating)==\(CGFloat(sliderForSight.sliderValue)) numReputability:\(numReputability * 10)==\(CGFloat(reputabilitySlide.sliderValue))")
        if numCougarSightings == CGFloat(self.sliderForCougar.sliderValue) && numVSrating == CGFloat(sliderForSight.sliderValue) && numNVSrating == CGFloat(sliderYelowSignt.sliderValue) && numReputability == CGFloat(reputabilitySlide.sliderValue)
        {
            blCheckEdit = false
             print("blCheckEdit:\(blCheckEdit)")
        }else{
             blCheckEdit = true
             print("blCheckEdit:\(blCheckEdit)")
        }
             print("blCheckEdit:\(blCheckEdit)")
    }
    
    func resetFilter(){
        //nsLayoutBottomLbl.constant = 0
        tblFilter.reloadData()
        SightingOff()
        sliderSetNull()
        coglideHide()
        
        blCheckEdit = false
        btnToday.isSelected = false
        btnWeek.isSelected = false
        btnMonth.isSelected = false
        btnAll.isSelected = false
        strValueDate = ""
        blSightSVS = false
        btnSiSVS.isSelected = false
        lblDisableSight.isHidden = true
        nsLayoutLblbgGray.constant = 0
        sliderForSight.isHidden = true
        nsLayoutSightHeight.constant = 110 + 38 + 10 + 38
        sliderForCougar.isHidden = true
        slidCogGray.isHidden = false
        btnCouSNVCS.isSelected = false
        btnCSiSOC.isSelected = false
        reputabilitySlide.setValueOfSlider(postition: 0.0)
        vwFullFilter.frame.size.height = intDefaultValue
        print("intvwFullHeight:\(intvwFullHeight)")
        tblFilter.reloadData()
        UserDefaults.standard.setValue(nil, forKey: "filterData")
        UserDefaults.standard.synchronize()
    }
 
    @IBAction func actionSubmit(_ sender: Any) {
        blCheckEdit = true
        presenter.gEtFilterApi()
        
    }
    @IBAction func actionSowSight(_ sender: Any) {
        blCheckEdit = true
    print("sighntin")
    }
     var intSheet = 0
    @IBAction func actionTotalSi(_ sender: Any) {
        var DataArray = [[String:Any]]()
        DataArray.append(["name":"10"])
        DataArray.append(["name":"20"])
        DataArray.append(["name":"30"])
        DataArray.append(["name":"40"])
        DataArray.append(["name":"50"])
      //  DataArray.append(["name":"All"])
    //   ActionSheetStringPicker.can
      ActionSheetStringPicker.show(withTitle: "Select Sightings", rows: DataArray, initialSelection: intSheet, doneBlock: {
                picker, value, index in
                print("value = \(value)")
                self.blCheckEdit = true
                //self.sexualPreId = value
        self.intSheet = value
        print("intSheet = \(self.intSheet)")
                print("index = \(String(describing: index))")
        let dictData:NSDictionary = index as! NSDictionary
        self.numTotalSightings = Int(dictData.value(forKey: "name")as! String)!
        self.btnTotalSi.setTitle(dictData.value(forKey: "name") as? String, for: .normal)
                return
            }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    func sheetOpen(){
        var DataArray = [[String:Any]]()
        DataArray.append(["name":"10"])
        DataArray.append(["name":"20"])
        DataArray.append(["name":"30"])
        DataArray.append(["name":"40"])
        DataArray.append(["name":"50"])
        
        ActionSheetStringPicker.show(withTitle: "Select Sightings", rows: DataArray, initialSelection: intSheet, doneBlock: {
            picker, value, index in
            self.blCheckEdit = true
            //self.sexualPreId = value
            self.intSheet = value
            print("intSheet = \(self.intSheet)")
          
            let dictData:NSDictionary = index as! NSDictionary
            self.numTotalSightings = Int(dictData.value(forKey: "name")as! String)!
            self.btnTotalSi.setTitle(dictData.value(forKey: "name") as? String, for: .normal)
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: nil)
    }
    
    @IBAction func actionCouSiSnvcS(_ sender: Any) {
        
        blCheckEdit = true
        if btnCouSNVCS.isSelected == true{
            
//            sliderForSight.isUserInteractionEnabled = true
//            lblDisableSight.isHidden = true
           btnCouSNVCS.isSelected = false
            sliderForCougar.isHidden = true
            slidCogGray.isHidden = false
            lblCogDisable.isHidden = false
            if btnCSiSOC.isSelected == true{
                strCougStatus = "ALL"
                sliderForCougar.isHidden = true
                slidCogGray.isHidden = false
            }else{
                strCougStatus = ""
                sliderForCougar.isHidden = false
                slidCogGray.isHidden = true
            }
        }else{
           strCougStatus = "NVS"
//             lblDisableSight.isHidden = false
//             sliderForSight.isUserInteractionEnabled = false
               btnCouSNVCS.isSelected = true
               btnCSiSOC.isSelected = false
               sliderForCougar.isHidden = false
               slidCogGray.isHidden = true
             lblCogDisable.isHidden = true
         
        }
    }
    
    @IBAction func actionCoSiSOC(_ sender: Any) {
       
        blCheckEdit = true
        if btnCSiSOC.isSelected == true
        {
            strCougStatus = ""

            btnCSiSOC.isSelected = false
            if btnCouSNVCS.isSelected == true{
                 strCougStatus = "NVS"
                sliderForCougar.isHidden = true
                slidCogGray.isHidden = false
            }else{
               strCougStatus = ""
                sliderForCougar.isHidden = false
                slidCogGray.isHidden = true
            }
           
            //intvwFullHeight = intvwFullHeight  + 110 + 38
            vwFullFilter.frame.size.height = intvwFullHeight
            print("intvwFullHeight:\(intvwFullHeight)")
            tblFilter.reloadData()
//            sliderForSight.isUserInteractionEnabled = true
//            lblDisableSight.isHidden = true
        }else{
            strCougStatus = "ALL"
            //sliderForSight.tintColor = UIColor.darkGray
            
            lblCogDisable.isHidden = false
            blSightSNVS = false
            blSightSVS = false
            SightingOff()
            intvwFullHeight = 1000
            vwFullFilter.frame.size.height = intvwFullHeight
            tblFilter.reloadData()
            sliderForCougar.isHidden = false
            slidCogGray.isHidden = true
            btnSiSVS.isSelected = false
            btnSiSNVS.isSelected = false
            btnCSiSOC.isSelected = true
        }
    }
    //
    @IBAction func actionSigSNVS(_ sender: Any) {
        blCheckEdit = true
        btnCSiSOC.isSelected = false
          lblDisableSight.isHidden = true
        if btnSiSNVS.isSelected == true{ // check show non verified sighting
            
            blSightSNVS = false
            btnSiSNVS.isSelected = false
            sliderYelowSignt.isHidden = true
            nsLayoutSightHeight.constant = 110 + 38 + 10 + 38
            
         
            tblFilter.reloadData()
            if blSightSVS == true{
                sliderForSight.isHidden = false
                nsLayoutVerifiSigh.constant = 5
                intvwFullHeight = intvwFullHeight - 110 - 38
                vwFullFilter.frame.size.height = intvwFullHeight
                tblFilter.reloadData()
                
            }else{
                 SightingOff()
            }
            
          
           
        }else{ // chek  show non verified sighting
            
            blSightSNVS = true
            btnSiSNVS.isSelected = true
            sliderGraySignt.isHidden = true
             if blSightSVS == true {
                bothSelected()

                }else{
               
                sliderForSight.isHidden = true
                sliderYelowSignt.isHidden = false
                nsLayoutLblbgGray.constant = 45
                nsLayoutVerifiSigh.constant = -100
                nsLayoutSdrYelo.constant = 48
                nsLayoutSightHeight.constant = 110 + 38 + 10 + 38
                
                
            }
        }
    }
    
    @IBAction func actionSigSVS(_ sender: Any) {
        blCheckEdit = true
        btnCSiSOC.isSelected = false
        if btnSiSVS.isSelected == true{ // unchek show verified sighting
            blSightSVS = false
           
            btnSiSVS.isSelected = false
            lblDisableSight.isHidden = true
            nsLayoutLblbgGray.constant = 0
          
            sliderForSight.isHidden = true
            nsLayoutSightHeight.constant = 110 + 38 + 10 + 38
            
            if blSightSNVS == true{  // if only one check
                sliderYelowSignt.isHidden = false
                nsLayoutSdrYelo.constant = 20 + 38
                nsLayoutVerifiSigh.constant = -100
                
                intvwFullHeight = intvwFullHeight - 110 - 38
                vwFullFilter.frame.size.height = intvwFullHeight
                tblFilter.reloadData()
            }else{
                SightingOff()
            }
            
        }else{ // chek show verified sighting
            btnSiSVS.isSelected = true
            blSightSVS = true
            sliderGraySignt.isHidden = true
          
            if blSightSNVS == true{  // if both are chekckd
               bothSelected()
            }else{
                nsLayoutLblbgGray.constant = 0
                nsLayoutVerifiSigh.constant = 5
                sliderForSight.isHidden = false
                sliderYelowSignt.isHidden = true
                nsLayoutSightHeight.constant = 110 + 38 + 10 + 38
            }
        }
    }
    
    func SightingOff(){
       // if blSightSNVS == false && blSightSVS == false{
            blSightSNVS = false
            blSightSVS = false
            btnSiSVS.isSelected = false
            btnCouSNVCS.isSelected = false
            btnSiSNVS.isSelected = false
            sliderGraySignt.isHidden = false
            sliderYelowSignt.isHidden = true
            sliderForSight.isHidden = true
            nsLayoutVerifiSigh.constant = 5
            nsLayoutSightHeight.constant = 110 + 38 + 10 + 38
            lblDisableSight.isHidden = false
         print("intvwFullHeight:\(intvwFullHeight)")
        vwFullFilter.frame.size.height = intvwFullHeight
        tblFilter.reloadData()
            //nsLayoutLblbgGray.constant =
       // }
    }
    
    func bothSelected(){
        nsLayoutLblbgGray.constant = 0
        nsLayoutVerifiSigh.constant = 5
        sliderForSight.isHidden = false
        sliderYelowSignt.isHidden = false
        nsLayoutSdrYelo.constant = 20 + 110 + 38
        nsLayoutSightHeight.constant = 110 + 38 + 10 + 110 + 38 + 10
        
        intvwFullHeight =  intvwFullHeight + 110 + 38 + 10
        vwFullFilter.frame.size.height = intvwFullHeight
        tblFilter.reloadData()
    }
    
    @IBAction func actionSigShowAl(_ sender: Any) {
        blCheckEdit = true
    }
    
    @IBAction func actionSiHelp(_ sender: Any) {
        blCheckEdit = true
    }
    
    @IBAction func actionCoSi(_ sender: Any) {
        blCheckEdit = true
    }
    
    @IBAction func actionRepu(_ sender: Any) {
        blCheckEdit = true
    }
    
    @IBAction func actionTotaSiHelp(_ sender: Any) {
        blCheckEdit = true
    }
    
    @IBAction func actionRepuShoAll(_ sender: Any) {
        blCheckEdit = true
    }
    
    @IBAction func actionCoSiHideSo(_ sender: Any) {
        blCheckEdit = true
        if btnCoSiHideSo.isSelected == true{
           blCougerHeight = false
           coglideHide()
        }else{
            
          cogSlideShow()
            
        }
        
    }
    func coglideHide(){
        vwCoSi.isHidden = true
        btnCoSiHideSo.isSelected = false
        vWCoSiNsLayout.constant = 5
         print("intvwFullHeight:\(intvwFullHeight)")
        if blCougerHeight != true{
        intvwFullHeight = intvwFullHeight - 200
        }
         print("intvwFullHeight:\(intvwFullHeight)")
        vwFullFilter.frame.size.height = intvwFullHeight
        tblFilter.reloadData()
        
    }
    
    func cogSlideShow(){
        vwCoSi.isHidden = false
        btnCoSiHideSo.isSelected = true
        vWCoSiNsLayout.constant = 200
        intvwFullHeight = intvwFullHeight + 200
        vwFullFilter.frame.size.height = intvwFullHeight
        print("intvwFullHeight: \(intvwFullHeight)")
        tblFilter.reloadData()
    }
}

extension EditFilterVc: RangeSeekSliderDelegate {
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {

    }
    
    func didStartTouches(in slider: RangeSeekSlider) {
        print("did start touches")
    }
    
    func didEndTouches(in slider: RangeSeekSlider) {
        print("did end touches")
    }
}

/*
 sliderType key is for image of scale
 
 here 5 mean yellow scale image
 
 and  6  for gray scale image
 */
