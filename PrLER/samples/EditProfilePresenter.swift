//
//  Presenter.swift
//  Prowler
//
//  Created by Admin on 4/22/18.
//  Copyright © 2018 RV09. All rights reserved.
//

import Foundation
import Alamofire
import PKHUD
import ALCameraViewController

class EditProfilePresenter{
    
    let view : EditProfileVC
    
    init(view: EditProfileVC){
        self.view = view
    }
    //MARK:- Init View
    func initView(){
        var userId:Int = 0
        if UserDefaults.standard.value(forKey: "userId") != nil  {
            userId = UserDefaults.standard.value(forKey: "userId") as! Int
        }
        let prm:Parameters  = ["userId": userId]
        MasterWebService.sharedInstance.Call_webServiceUtility(Url:  EndPoints.GetSetUserDetail_URL, useServerRoot: true, prm: prm, auth: true, background: true, methodType: .get, endcodingTyp:URLEncoding.queryString , completion: {
            _result,_statusCode in
            if _statusCode == 200 {
                if _result is NSDictionary {
                    print("dict")
                    print(_result)
                    let Responsedata: NSDictionary = _result as! NSDictionary
                    let res : NSDictionary =  Responsedata.value(forKey: "response") as!  NSDictionary
                    let status:Int = res.value(forKey: "status") as! Int
                    
                    if status == 0 {
                        let message : String = res.value(forKey: "message") as! String
                        self.view.showErrorToast(message: "\(message)", backgroundColor: UIColor.red)
                    }else  if status == 1 {
                        var userDict : NSDictionary = NSDictionary()
                        userDict  =  res.value(forKey: "userDetail") as!  NSDictionary
                        self.userDataPopulate(userData:userDict)
                    }
                }
            }
        })
    }
    
    //MARK:-DATA Population in VIEW
    func userDataPopulate(userData:NSDictionary){
        self.view.imgForEditUserName.isHidden = false
        self.view.btnForEditUserName.isHidden = false
        
        if userData.value(forKey: "profilePic") != nil && userData.value(forKey: "profilePic") as! String != "" {
            self.view.profilePicUrl = userData.value(forKey: "profilePic") as! String
            var url:URL?
            
            if !self.view.profilePicUrl.contains("http") {
                let key: String = userData.value(forKey: "profilePic") as! String
                url = URL.init(string:"https://d1i8kderre600j.cloudfront.net/" + key)
            }else{
                url = URL.init(string:userData.value(forKey: "profilePic") as! String)
            }
            self.view.imgForProPic.sd_setImage(with: url , placeholderImage: UIImage(named: "defaultProfilPic.png"))
            self.view.imgForProPic.imageCircular()
            self.view.imgForShadow.imageCircularShadow()
            
            //self.setImage = true
        }
        
        self.view.txtFieldForFirstName.text = userData.value(forKey: "firstName") as? String
        self.view.txtFieldForLastName.text = userData.value(forKey: "lastName") as? String
        self.view.txtFieldForEmailId.text = userData.value(forKey: "email") as? String
        self.view.txtFieldForPhoneNumber.text = userData.value(forKey: "phoneNo") as? String
        self.view.txtFieldForUserName.text = userData.value(forKey: "username") as? String
        self.view.countryId =  userData.value(forKey: "countryId") as! Int
        self.view.stateId =  userData.value(forKey: "stateId") as! Int
        self.view.cityId =  userData.value(forKey: "cityId") as! Int
        self.view.sexualPreId = userData.value(forKey: "sexualPrefrenceId") as! Int
        
        self.view.lableForGender.text = userData.value(forKey: "gender") as? String
        self.view.lableForGender.textColor = .black
        if self.view.sexualPreId != 0 {
            let filerData1 = EndPoints.sexualPreArr.filter{ ($0["id"] as! Int) == self.view.sexualPreId}
            if filerData1.count > 0 {
                self.view.lableForSexualPre.text =  filerData1[0].value(forKey: "name") as? String
                self.view.lableForSexualPre.textColor = .black
            }
        }
        let filerData2 = EndPoints.countryArr.filter{ ($0["id"] as! Int) == self.view.countryId}
        if filerData2.count > 0 {
            self.view.lableForCountry.text =  filerData2[0].value(forKey: "name") as? String
            self.view.lableForCountry.textColor = .black
        }
        MasterWebService.sharedInstance.Call_webServiceUtility(Url: "api/Countries/\(self.view.countryId)/states", useServerRoot: true, prm: [:], auth: false, background: true, methodType: .get, endcodingTyp:URLEncoding.queryString , completion: {
            //MasterWebService.sharedInstance.GET_webservice(Url:"api/Countries/\(self.countryId)/states", useServerRoot: true, background: true, completion: {
            _result,_statusCode in
            if _statusCode == 200 {
                if _result is NSArray {
                    self.view.stateArr =  _result as! [NSDictionary]
                    print(self.view.stateArr)
                    let filerData = self.view.stateArr.filter{ ($0["id"] as! Int) == self.view.stateId}
                    if filerData.count > 0 {
                        self.view.lableForState.text =  filerData[0].value(forKey: "name") as? String
                        self.view.lableForState.textColor = .black
                    }
                    MasterWebService.sharedInstance.Call_webServiceUtility(Url: "api/States/\(self.view.stateId)/cities/", useServerRoot: true, prm: [:], auth: false, background: true, methodType: .get, endcodingTyp:URLEncoding.queryString , completion: {
                        _result,_statusCode in
                        if _statusCode == 200 {
                            if _result is NSArray {
                                self.view.cityArr =  _result as! [NSDictionary]
                                print(self.view.cityArr)
                                let filerData = self.view.cityArr.filter{ ($0["id"] as! Int) == self.view.cityId}
                                if filerData.count > 0 {
                                    self.view.lableForCity.text =  filerData[0].value(forKey: "name") as? String
                                    self.view.lableForCity.textColor = .black
                                }
                            }
                        }
                    })
                }
            }
        })
    }
    
    
    //MARK:- Call Update API
    func updateUserData(email:String,username:String,firstname:String,lastname:String,phoneNo:String,profilePic:String,gender:String){
        let prm:Parameters  = [
            "email": email,
            "username": username,
            "firstName" : firstname,
            "lastName" : lastname,
            "sexualPrefrenceId" : self.view.sexualPreId,
            "phoneNo" : phoneNo,
            "profilePic" : profilePic,
            "countryId" : self.view.countryId,
            "stateId" : self.view.stateId,
            "cityId" : self.view.cityId,
            "gender" : gender,
            "userId" : UserDefaults.standard.value(forKey: "userId") as! Int
        ]
        MasterWebService.sharedInstance.Call_webServiceUtility(Url: EndPoints.GetSetUserDetail_URL, useServerRoot: true, prm: prm, auth: true, background: false, methodType: .put, endcodingTyp:JSONEncoding.default , completion: {
            _result,_statusCode in
            if _statusCode == 200 {
                if _result is NSDictionary {
                    print("dict")
                    print(_result as Any)
                    let Responsedata: NSDictionary = _result as! NSDictionary
                    let res : NSDictionary =  Responsedata.value(forKey: "response") as!  NSDictionary
                    let _:Int = res.value(forKey: "status") as! Int
                    let message : String = res.value(forKey: "message") as! String
                    MasterFunctions.sharedInstance.setDictInNSDefaulte(dict: res.value(forKey: "userDetail")  as! NSDictionary, key: "userData")
                    self.view.showErrorToast(message: "\(message)", backgroundColor: UIColor(red: 119.0/255, green: 34.0/255, blue: 206.0/255, alpha: 1.0))
                }
            }
        })
    }
    
    //MARKL: - Set Drop Down Data
    func setDropDownsData(url:String,arrFlag:Int){
        MasterWebService.sharedInstance.Call_webServiceUtility(Url: url, useServerRoot: true, prm: [:], auth: false, background: true, methodType: .get, endcodingTyp:URLEncoding.queryString , completion: {
            _result,_statusCode in
            if _statusCode == 200 {
                if _result is NSArray {
                    if arrFlag == 0 {
                        self.view.stateArr =  _result as! [NSDictionary]
                        print(self.view.stateArr)
                    }
                    else if arrFlag == 1 {
                        self.view.cityArr =  _result as! [NSDictionary]
                        print(self.view.cityArr)
                    }
                    
                }
            }
        })
        
    }
    
    //MARK:- Call Local validation Service
    func callLocalValidation(){
        let firstname = self.view.txtFieldForFirstName.text
        let lastname :String = self.view.txtFieldForLastName.text!
        let username  = self.view.txtFieldForUserName.text
        let email     = self.view.txtFieldForEmailId.text
        let phoneNo  = self.view.txtFieldForPhoneNumber.text
        let gender  = self.view.lableForGender.text
        let city    = self.view.lableForCity.text
        let state   = self.view.lableForState.text
        let country = self.view.lableForCountry.text
        let sexualPrefernce = self.view.lableForSexualPre.text!
        let validateDict:NSDictionary =  MasterFunctions.sharedInstance.FormValidation(firstName: firstname!, lastName: lastname, userName: username!, email: email!, phoneNo: phoneNo!, hasPasswordField: false, password: "", confirmPassword: "", sexualPreference: sexualPrefernce, gender: gender!, country: country!, state: state!, city: city!)
        if  validateDict.value(forKey: "errorFlag") as! Bool {
            if self.view.setImage{
                HUD.show(.progress)
                let img = self.view.imgForProPic.image
                MasterFunctions.sharedInstance.UploadAWSImageForChatChat(image: img!)
            }else{
                //HUD.show(.progress)
                /*if btnForSave.titleLabel?.text == "Sign up" && self.textForTitle != ""  {
                 let imgUrl = self.socialDict.value(forKey: "picture") as! String
                 signUp_service(email: email!,  username: username!, firstname: firstname!, lastname:lastname ,  phoneNo: phoneNo!, profilePic:imgUrl )
                 }else{*/
                updateUserData(email: email!, username: username!, firstname: firstname!, lastname: lastname, phoneNo: phoneNo!, profilePic: self.view.profilePicUrl, gender: gender!)
                // }
            }
        }else{
            self.view.showErrorToast(message: validateDict.value(forKey: "errorMsg") as! String, backgroundColor: .red)
        }
    }
    
    
    
    
    
    //MARK:-Font Setup
    func FontSetup(){
        self.view.txtFieldForFirstName.font = FontNormal15
        self.view.txtFieldForLastName.font = FontNormal15
        self.view.txtFieldForUserName.font = FontNormal15
        self.view.txtFieldForEmailId.font = FontNormal15
        self.view.lableForSexualPre.font = FontNormal15
        self.view.txtFieldForPhoneNumber.font = FontNormal15
        self.view.lableForGender.font = FontNormal15
        self.view.lableForCountry.font = FontNormal15
        self.view.lableForCity.font = FontNormal15
        self.view.lableForState.font = FontNormal15
        self.view.lblForEditProfile.font = FontBold18
        self.view.btnForSave.titleLabel?.font = FontBold18
        
    }
    
    //MARK:-check is user name is avaible or not
    func UserName_Avaible(SearchText:String){
        MasterFunctions.sharedInstance.UserName_Avaible(SearchText:SearchText, completion: {_statusCode  in
            if _statusCode == 1 {
               self.view.imgForValidateUserName.image = UIImage(named: "Validated_icon.png")
                self.view.imgForValidateUserName.isHidden = false
            }else{
                self.view.imgForValidateUserName.image = UIImage(named: "declined_icon.png")
                self.view.imgForValidateUserName.isHidden = false
                print("failed")
            }
        })
    }
    
    //MARK: -Open Camera
    func openCameraActionSheet(){
        var croppingParameters: CroppingParameters {
            return CroppingParameters(isEnabled: true, allowResizing: true, allowMoving: false, minimumSize: CGSize(width: 60, height: 60))
        }
        let actionSheetController = UIAlertController(title: NSLocalizedString("Select", comment: ""), message: NSLocalizedString("PHOTO!", comment: ""), preferredStyle: .actionSheet)
        let cancelActionButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        let saveActionButton = UIAlertAction(title: NSLocalizedString("Image from camera", comment: ""), style: .default) { action -> Void in
            let cameraViewController = CameraViewController(croppingParameters: croppingParameters, allowsLibraryAccess: true) { [weak self] image, asset in
                if image != nil {
                self?.view.imgForProPic.image = image
                self?.view.imgForProPic.imageCircular()
                self?.view.imgForShadow.imageCircularShadow()
                self?.view.setImage = true
                }
                self?.view.dismiss(animated: true, completion: nil)
            }
            self.view.present(cameraViewController, animated: true, completion: nil)
        }
        actionSheetController.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: NSLocalizedString("Choose from gallery", comment: ""), style: .default) { action -> Void in
            
            let libraryViewController = CameraViewController.imagePickerViewController(croppingParameters: croppingParameters) { [weak self] image, asset in
                if image != nil {
                self?.view.imgForProPic.image = image
                self?.view.imgForProPic.imageCircular()
                self?.view.imgForShadow.imageCircularShadow()
                self?.view.setImage = true
                }
                self?.view.dismiss(animated: true, completion: nil)
            }
            self.view.present(libraryViewController, animated: true, completion: nil)
        }
        actionSheetController.addAction(deleteActionButton)
        self.view.present(actionSheetController, animated: true, completion: nil)
        
    }
    
}
