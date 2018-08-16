//
//  NotificationSettingsVC.swift
//  Prowler
//
//  Created by dev5 on 2/22/18.
//  Copyright © 2018 dev. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
class NotificationSettingsVC: UIViewController {
    
    @IBOutlet weak var lblForNotificationSettings: UILabel!
    @IBOutlet weak var viewForCornerRadius: UIView!
    @IBOutlet weak var viewForCougarSightings: UIView!
    @IBOutlet weak var viewForNVSSightings: UIView!
    @IBOutlet weak var btnForCougarSightings: UIButton!
    @IBOutlet weak var btnForNVSSightings: UIButton!
    var strTypeSight = "nvssight"
    @IBOutlet var sliderForScored: HDoubleBarSliderView!
    @IBOutlet var sliderForRadius: HDoubleBarSliderView!
    @IBOutlet weak var btnMute: UIButton!
    @IBOutlet weak var btnNvs: UIButton!
    @IBOutlet weak var btnPush: UIButton!
    
    @IBOutlet var nvsSlideSight: HDoubleBarSliderView!
    @IBOutlet var nvsSlideRadius: HDoubleBarSliderView!
    //Local Variable Declartion
    var dictNotifi = NSDictionary()
    var menuText: [String] = ["Push","NVS","Mute"]
    var menuImg = ["on_notifySettings", "off_notifySettings", "mute_off_notifySettings"]
    var blPush = true
    var blNvs = true
    var blMute = true
    
    var intRadiousMin = CGFloat()
    var intRadiousMax = CGFloat()
    var intSightingRat = CGFloat()
    
    var nvsIntRadiousMin = CGFloat()
    var nvsIntRadiousMax = CGFloat()
    var nvsIntSightingRat = CGFloat()
    
    lazy var presenter = NotificationSettingsVCPresenter(view: self)
    var bombSoundEffect: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewForCornerRadius.layer.cornerRadius = 10.0
        viewForCornerRadius.clipsToBounds = true
        viewForCornerRadius.layer.borderWidth = 1
        viewForCornerRadius.layer.borderColor = UIColor.gray.cgColor

        self.presenter.gEtnotificationSettingApi() //
    }
    
    //MARK: Custom Methods
    func FontSetup(){
        lblForNotificationSettings.font = FontBold20
        btnForCougarSightings.titleLabel?.font = FontNormal16
        btnForNVSSightings.titleLabel?.font = FontBold16
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        FontSetup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
    }
    
    @IBAction func actionForCougarSightings(_ sender: UIButton){
        strTypeSight = "cougersight"
        viewForNVSSightings.backgroundColor = UIColor(red: 230.0/255, green: 230.0/255, blue: 230.0/255, alpha: 1.0)
        viewForCougarSightings.backgroundColor = UIColor(red: 119.0/255, green: 34.0/255, blue: 206.0/255, alpha: 1.0)
        btnForNVSSightings.setTitleColor(.black, for: .normal)
        btnForCougarSightings.setTitleColor(.white, for: .normal)
        btnForCougarSightings.titleLabel?.font = FontNormal16
        btnForNVSSightings.titleLabel?.font = FontBold16
        nvsSlideRadius.isHidden = true
        nvsSlideSight.isHidden = true
        sliderForScored.isHidden = false
        sliderForRadius.isHidden = false
     
        
    }
    
    @IBAction func actionForNVSSightings(_ sender: UIButton) {
    strTypeSight = "nvssight"
    viewForCougarSightings.backgroundColor = UIColor(red: 230.0/255, green: 230.0/255, blue: 230.0/255, alpha: 1.0)
    viewForNVSSightings.backgroundColor = UIColor(red: 119.0/255, green: 34.0/255, blue: 206.0/255, alpha: 1.0)
    btnForCougarSightings.setTitleColor(.black, for: .normal)
    btnForNVSSightings.setTitleColor(.white, for: .normal)
    btnForCougarSightings.titleLabel?.font = FontBold16
    btnForNVSSightings.titleLabel?.font = FontNormal16
    nvsSlideRadius.isHidden = false
    nvsSlideSight.isHidden = false
    sliderForScored.isHidden = true
    sliderForRadius.isHidden = true
    
    }
    
    func playSound()
    {
        let path = Bundle.main.path(forResource: "switch-1.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            bombSoundEffect = try AVAudioPlayer(contentsOf: url)
            bombSoundEffect?.play()
        } catch {
            
        }
    }
    
    @IBAction func actionPush(_ sender: Any) {
        if btnPush.isSelected{
            btnPush.isSelected = false
            blPush = false
            playSound()
        }else{
            btnPush.isSelected = true
            blPush = true
            playSound()
        }
        self.presenter.PushnotificationSettingApi()
    }
    
    @IBAction func actionNvs(_ sender: Any) {
    
        if btnNvs.isSelected{
            btnNvs.isSelected = false
            blNvs = false
            playSound()
        }else{
            btnNvs.isSelected = true
            blNvs = true
            playSound()
        }
        self.presenter.nVsnotificationSettingApi()
        //}
    }
    
    @IBAction func actionMute(_ sender: Any) {

        if btnMute.isSelected{
            blMute = false
            btnMute.isSelected = false
        }else{
            blMute = true
            btnMute.isSelected = true
            playSound()
        }
        self.presenter.mUtenotificationSettingApi()
        // }
    }
    
    @IBAction func ActionOnBack(_ sender: Any) {
        print("self.view.intRadiousMax:\(self.intRadiousMax)-------self.view.intRadiousMin:\(self.intRadiousMin)------self.view.intSightingRat\(self.intSightingRat)")
        
        print("self.view.nvsIntRadiousMax:\(self.nvsIntRadiousMax)------- self.view.nvsIntRadiousMin:\( self.nvsIntRadiousMin)------self.view.nvsIntSightingRat\(self.nvsIntSightingRat)")
        self.NotiSlider()
       
    }
    
    func NotiSlider(){
        
        print("self.view.blMute!--\(self.blMute)--------self.view.blMute!--\(self.blNvs)")
        
        var radimax = CGFloat()
        var radimin = CGFloat()
        var RadiSightmin = CGFloat()
        
        var nvsmax = CGFloat()
        var nvsmin = CGFloat()
        var nvsSightmin = CGFloat()
        
        print("self.view.intRadiousMax:\(self.intRadiousMax)-------self.view.intRadiousMin:\(self.intRadiousMin)------self.view.intSightingRat\(self.intSightingRat)")
      
        
          print("self.sliderForRadius.sliderSecondValue:\(self.sliderForRadius.sliderSecondValue)-------self.sliderForRadius.sliderValue:\(self.sliderForRadius.sliderValue)-------------self.sliderForScored.sliderValue:\(self.sliderForScored.sliderValue)--------self.nvsSlideRadius.sliderSecondValue:\(self.nvsSlideRadius.sliderSecondValue)--------self.sliderForRadius.sliderValue:\(self.nvsSlideRadius.sliderValue)--------self.sliderForRadius.sliderValue:\(self.sliderForRadius.sliderValue)--------self.sliderForRadius.sliderValue:\(self.sliderForRadius.sliderValue)-------")
        
        self.intRadiousMax = CGFloat(self.sliderForRadius.sliderSecondValue)
        self.intRadiousMin = CGFloat(self.sliderForRadius.sliderValue)
        self.intSightingRat = CGFloat(self.sliderForScored.sliderValue)
        self.nvsIntRadiousMax = CGFloat(self.nvsSlideRadius.sliderSecondValue)
        self.nvsIntRadiousMin = CGFloat(self.nvsSlideRadius.sliderValue)
        self.nvsIntSightingRat = CGFloat(self.nvsSlideSight.sliderValue)
  
        
        if self.intRadiousMax < self.intRadiousMin{
            radimin = self.intRadiousMax
            radimax = self.intRadiousMin
        }else{
            radimin = self.intRadiousMin
            radimax = self.intRadiousMax
        }
        
        if self.nvsIntRadiousMax < self.nvsIntRadiousMin{
            nvsmin = self.nvsIntRadiousMax
            nvsmax = self.nvsIntRadiousMin
        }else{
            nvsmin = self.nvsIntRadiousMin
            nvsmax = self.nvsIntRadiousMax
        }
        
        let prm:Parameters  = ["userId": UserDefaults.standard.value(forKey: "userId") as! Int, //1
            "isPushEnabled": self.blPush, //2
            "isMute":self.blMute, //3
            "isNVSEnable": self.blNvs, //4
            "cougarSightingRadiusTo": radimax, //5 max
            "cougarSightingRadiusFrom":radimin, //6min
            "cougarSightingScore": self.intSightingRat, //7
            "NVSSightingRadiusTo": nvsmax, //8max
            "NVSSightingRadiusFrom":nvsmin, //9min
            "NVSSightingScore": self.nvsIntSightingRat] //10
            print("prm\(prm)")
        MasterWebService.sharedInstance.Call_webServiceUtility(Url:EndPoints.NotificationSet_URL, useServerRoot: true, prm: prm, auth: true, background: true, methodType: .post, endcodingTyp:JSONEncoding.default , completion: {
            _result,_statusCode in
            DispatchQueue.main.async {
                if _statusCode == 200
                {
                    if _result is NSDictionary
                    {
                        print(_result)
                        let data =  _result.value(forKey: "response")as! NSDictionary
                        print("data value : \(data)")
                        let ResponseData:NSDictionary = _result as! NSDictionary
                        if let status:Int = data.value(forKey: "status") as!Int{
                            // let status:Int = ResponseData.value(forKey: "status") as!Int
                            
                            if status == 0
                            {
                                let message:String = ResponseData.value(forKey: "message") as! String
                                self.showErrorToast(message: message, backgroundColor: .red)
                                
                            }
                            else if status == 1
                            {
                 
                            }
                        }
                    }
                }else
                {
                    self.showErrorToast(message:NSLocalizedString("something_went_wrong_error", comment: ""), backgroundColor: .red)
                }
                self.navigationController?.popViewController(animated: true)
            }
        })
        
    }
    
}


/*
 ////
 sliderType . : this param use for bar images  
 eg. 1 for purple image with purple bar
         2  for red bar scale
         3 for purple scale and arrow bar
  here 5 mean yellow scale image
 and  6  for gray scale image
 hasBottomLeftBtn : to show bottom left botton 
 hasTwoBars: for two bar slider  
 scaleType : This param is used for scale size like 10 or 100 or 1000 
// eg. 1 default for 10
         2 for  1000
         3 for  100
 // for 1000 scale you need to divid by 100
 // for 100 scale you need to divid by 10
 // here for bar is ussed to represent second slider bar
 */
