//
//  NotificationSettingsVCPresenter.swift
//  Prowler
//
//  Created by Admin on 7/9/18.
//  Copyright © 2018 dev. All rights reserved.
//

import Foundation
import Alamofire

class NotificationSettingsVCPresenter{
    let view : NotificationSettingsVC
    var dictset = NSDictionary()
    init(view: NotificationSettingsVC){
        self.view = view
    }
    
    /*
     "{
     ""userId"": number,
     ""isPushEnabled"": boolean,
     ""isMute"": boolean,
     ""isNVSEnable"": boolean,
     ""cougarSightingRadiusTo"": number,
     ""cougarSightingRadiusFrom"": number,
     ""cougarSightingScore"": number,
     ""NVSSightingRadiusTo"": number,
     ""NVSSightingRadiusFrom"": number,
     ""NVSSightingScore"": number
     }"
 */
    
    
    //35 MutenotificationSettingApi
    func mUtenotificationSettingApi(){
        print("self.view.blMute-- \(self.view.blMute)---self.view.blMute-- \(self.view.blMute)")
        let prm:Parameters  = ["userId": UserDefaults.standard.value(forKey: "userId") as! Int, //1
            "isPushEnabled": self.view.blPush, //2
            "isMute":self.view.blMute, //3
            "isNVSEnable": self.view.blNvs, //4
            "cougarSightingRadiusTo": 10, //5
            "cougarSightingRadiusFrom":5, //6
            "cougarSightingScore": 50, //7
            "NVSSightingRadiusTo": 10, //8
            "NVSSightingRadiusFrom":5, //9
            "NVSSightingScore": 5] //10
        
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
                                self.view.showErrorToast(message: message, backgroundColor: .red)
                                
                            }
                            else if status == 1
                            {
          
                            }
                        }
                    }
                }else
                {
                    self.view.showErrorToast(message:NSLocalizedString("something_went_wrong_error", comment: ""), backgroundColor: .red)
                }
            }
        })
    }
    
    //34 NvsnotificationSettingApi
    func nVsnotificationSettingApi(){
        let prm:Parameters  = ["userId": UserDefaults.standard.value(forKey: "userId") as! Int, //1
            "isPushEnabled": self.view.blPush, //2
            "isMute":self.view.blMute, //3
            "isNVSEnable": self.view.blNvs, //4
            "cougarSightingRadiusTo": 10, //5
            "cougarSightingRadiusFrom":5, //6
            "cougarSightingScore": 50, //7
            "NVSSightingRadiusTo": 10, //8
            "NVSSightingRadiusFrom":5, //9
            "NVSSightingScore": 5] //10
        
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
                                self.view.showErrorToast(message: message, backgroundColor: .red)
                                
                            }
                            else if status == 1
                            {
               
                            }
                        }
                    }
                }else
                {
                    self.view.showErrorToast(message:NSLocalizedString("something_went_wrong_error", comment: ""), backgroundColor: .red)
                }
            }
        })
    }
    
    //33 PushnotificationSettingApi
    func PushnotificationSettingApi(){
        print("self.view.blMute!--\(self.view.blMute)--------self.view.blMute!--\(self.view.blNvs)")
        
        let prm:Parameters  = ["userId": UserDefaults.standard.value(forKey: "userId") as! Int, //1
                               "isPushEnabled": self.view.blPush, //2
                               "isMute":self.view.blMute, //3
            "isNVSEnable": self.view.blNvs, //4
            "cougarSightingRadiusTo": "25", //5
            "cougarSightingRadiusFrom":5, //6
            "cougarSightingScore": 50, //7
            "NVSSightingRadiusTo": 10, //8
            "NVSSightingRadiusFrom":5, //9
            "NVSSightingScore": 5] //10
        
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
                        self.view.showErrorToast(message: message, backgroundColor: .red)
                        
                    }
                    else if status == 1
                    {
                        
                    }
                    }
                }
            }else
            {
                self.view.showErrorToast(message:NSLocalizedString("something_went_wrong_error", comment: ""), backgroundColor: .red)
            }
        }
        })
    }
    

    
    //32 GetNotificationSettingApi
    
    func gEtnotificationSettingApi(){
        //--------
        self.view.sliderForRadius.InitialSetup(sliderType: 2, hasBottomLeftBtn: true, hasTwoBars: true, devicWidth: self.view.self.view.frame.width, scaleType: 2)
        
        self.view.sliderForScored.InitialSetup(sliderType: 7, hasBottomLeftBtn: true, hasTwoBars: false, devicWidth: self.view.self.view.frame.width, scaleType: 1)
        
        self.view.nvsSlideRadius.InitialSetup(sliderType: 1, hasBottomLeftBtn: true, hasTwoBars: true, devicWidth: self.view.self.view.frame.width, scaleType: 2)
        
        self.view.nvsSlideSight.InitialSetup(sliderType: 3, hasBottomLeftBtn: true, hasTwoBars: false, devicWidth: self.view.self.view.frame.width, scaleType: 1)
        //------------
           if MasterWebService.sharedInstance.Check_networkConnectionLocation() {
        let prm:Parameters  = ["userId": UserDefaults.standard.value(forKey: "userId") as! Int] //1
      MasterWebService.sharedInstance.Call_webServiceUtility(Url:EndPoints.GetNotificationSet_URL, useServerRoot: true, prm: prm, auth: true, background: false, methodType: .get, endcodingTyp:URLEncoding.default , completion: {
            _result,_statusCode in
         DispatchQueue.main.async {
            
            
            
            if _statusCode == 200
            {
                if _result is NSDictionary
                {
                    //print(_result)
                    let ResponseData:NSDictionary = _result as! NSDictionary
                    let dictdata = _result.value(forKey: "response")as! NSDictionary
                    
                    let status:Int = dictdata.value(forKey: "status") as!Int
                    
                    if status == 0
                    {
                        let message:String = dictdata.value(forKey: "message") as! String
                        self.view.showErrorToast(message: message, backgroundColor: .red)
                    }
                    else if status == 1
                    {
                        let data =  dictdata.value(forKey: "notificationSetting")as! NSDictionary
                        self.dictset = dictdata.value(forKey: "notificationSetting")as! NSDictionary
                        self.view.blMute = data.value(forKey: "isMute") as! Bool
                        if self.view.blMute == true{
                            self.view.btnMute.isSelected = true
                        }else{
                            self.view.btnMute.isSelected = false
                        }
                        
                        self.view.blNvs = data.value(forKey: "isNVSEnable") as! Bool
                        if self.view.blNvs == true{
                            self.view.btnNvs.isSelected = true
                        }else{
                            self.view.btnNvs.isSelected = false
                        }
                        self.view.blPush = data.value(forKey: "isPushEnabled") as! Bool
                        if self.view.blPush == true{
                            self.view.btnPush.isSelected = true
                        }else{
                            self.view.btnPush.isSelected = false
                        }
       
                        self.view.nvsIntRadiousMax = (data.value(forKey: "NVSSightingRadiusTo") as! CGFloat)/100.00
                        self.view.nvsIntRadiousMin = (data.value(forKey: "NVSSightingRadiusFrom") as! CGFloat)/100.00
                        self.view.nvsIntSightingRat = data.value(forKey: "NVSSightingScore") as! CGFloat
                        
                        self.view.intRadiousMax = (data.value(forKey: "cougarSightingRadiusTo") as! CGFloat)/100
                        self.view.intRadiousMin = (data.value(forKey: "cougarSightingRadiusFrom") as! CGFloat)/100
                        self.view.intSightingRat = data.value(forKey: "cougarSightingScore") as! CGFloat
                        
                         print("NVS self.view.nvsIntRadiousMax :\(CGFloat(self.view.intRadiousMax)) ------self.view.nvsIntRadiousMin :\(CGFloat(self.view.nvsIntRadiousMin))---self.view.nvsIntSightingRat :\(self.view.intSightingRat)")
                        
                        self.view.sliderForRadius.setValueOfSlider(postition: CGFloat(self.view.intRadiousMax),forBar: 2)
                        self.view.sliderForRadius.setValueOfSlider(postition: CGFloat(self.view.intRadiousMin))
                        self.view.sliderForScored.setValueOfSlider(postition: self.view.intSightingRat)
                        
                        self.view.nvsSlideRadius.setValueOfSlider(postition: CGFloat(self.view.nvsIntRadiousMin))
                         self.view.nvsSlideRadius.setValueOfSlider(postition: CGFloat(self.view.nvsIntRadiousMax),forBar: 2)
                        self.view.nvsSlideSight.setValueOfSlider(postition: CGFloat(self.view.nvsIntSightingRat))
                        
                    }
                }
            }else
            {
                self.view.showErrorToast(message:NSLocalizedString("something_went_wrong_error", comment: ""), backgroundColor: .red)
            }
        }
        })
           }else{
            self.view.sliderForRadius.setValueOfSlider(postition:0,forBar: 2)
            self.view.sliderForRadius.setValueOfSlider(postition: 0)
            self.view.sliderForScored.setValueOfSlider(postition: 0)
            
            self.view.nvsSlideRadius.setValueOfSlider(postition: 0)
            self.view.nvsSlideRadius.setValueOfSlider(postition: 0,forBar: 2)
            self.view.nvsSlideSight.setValueOfSlider(postition: 0)
        }
    }
}
