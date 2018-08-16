//
//  Presenter.swift
//  Prowler
//
//  Created by Admin on 4/22/18.
//  Copyright © 2018 RV09. All rights reserved.
//

import Foundation
import Alamofire

class PinPresenter{
    
    let view : PinVC
    
    init(view: PinVC){
        self.view = view
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var strToken:String?
    //Pin Verification
    func PinCheck(SearchText:String){
        let DeviceBattryLevel : Float = UIDevice.current.batteryLevel
        let prm :Parameters  = [
            "otp": Int(SearchText)!,
            "email": self.view.email,
            "socialId":self.view.soicalId,
            "username":self.view.userName,
            "accountType" : self.view.accountType,
            "deviceInfo": [
                "os": "iOS",
                "osVer": DeviceOSVersion,
                "devModel":Device_MOdel_name.rawValue,
                "resWidth" : DeviceSize.width,
                "resHeight" : DeviceSize.height,
                "appVer": "0.1",
                "battery": DeviceBattryLevel,
                "device_token":strToken
            ]
        ]
        MasterWebService.sharedInstance.Call_webServiceUtility(Url: EndPoints.VerifyOTP_URL, useServerRoot: true, prm: prm, auth: false, background: false, methodType: .post, endcodingTyp:JSONEncoding.default , completion: {
            _result,_statusCode in
            //   print(_result) as! Any
            if _statusCode == 200 {
                if _result is NSDictionary {
                    print("dict")
                    print(_result)
                    let Responsedata: NSDictionary = _result as! NSDictionary
                    let status : Int =  Responsedata.value(forKey: "status") as! Int
                    self.view.imgForVerified.isHidden = false
                    if status == 1 {
                        UserDefaults.standard.setValue(Responsedata.value(forKey: "authToken") as! String, forKey: "token")
                        let userData:NSDictionary =  Responsedata.value(forKey: "userDetail")  as! NSDictionary
                        UserDefaults.standard.setValue(userData.value(forKey: "id") as! Int, forKey: "userId")
                        MasterFunctions.sharedInstance.setDictInNSDefaulte(dict:userData , key: "userData")
                        self.view.imgForVerified.image = UIImage(named: "Pin_right.png")
                        self.view.btnForResend.setTitle("Activate Account", for: .normal)
                        self.view.isPinValidate = true
                        self.view.btnForResend.setBackgroundImage(UIImage(named:"Pin_purpal_button.png"), for: .normal)
                        self.view.txtFieldForPin.isUserInteractionEnabled = false
                    }else{
                        self.view.isPinValidate = false
                        self.view.imgForVerified.image = UIImage(named: "declined_icon.png")
                        print("failed")
                        self.view.btnForResend.setTitle("Resend PIN", for: .normal)
                      self.view.btnForResend.setBackgroundImage(UIImage(named:"Pin_gray_button.png"), for: .normal)
                        self.view.showErrorToast(message:Responsedata.value(forKey: "message") as! String , backgroundColor:.red)
                    }
                }
                
            }
        })
        
    }
    
    //Resend mail For verification
    func resend_varification_mail(){
        let prm:Parameters  = ["email": self.view.email,"socialId": self.view.soicalId,"username":self.view.userName]
        MasterWebService.sharedInstance.Call_webServiceUtility(Url:EndPoints.Resend_URL, useServerRoot: true, prm: prm, auth: false, background: false, methodType: .post, endcodingTyp:JSONEncoding.default , completion: {
            _result,_statusCode in
            if _statusCode == 200
            {
                if _result is NSDictionary
                {
                    print(_result)
                    let ResponseData:NSDictionary = _result as! NSDictionary
                    let status:Int = ResponseData.value(forKey: "status") as!Int
                    
                    if status == 0
                    {
                        let message:String = ResponseData.value(forKey: "message") as! String
                        self.view.showErrorToast(message: message, backgroundColor: .red)
                        
                    }
                    else if status == 1
                    {
                        PinVerify().addDiaLogToView(callback: {
                            (dict, bool) in
                            print(dict ?? "nul", bool ?? "nul")
                        })
                    }
                }
            }else
            {
                self.view.showErrorToast(message:NSLocalizedString("something_went_wrong_error", comment: ""), backgroundColor: .red)
            }
        })
        
    }
    
}
