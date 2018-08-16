 //
 //  Presenter.swift
 //  Prowler
 //
 //  Created by Admin on 4/22/18.
 //  Copyright © 2018 RV09. All rights reserved.
 //
 
 import Foundation
 import PKHUD
 import Alamofire
 import MapKit
 
 class HomePresenter{
    
    let view : HomeVC
    init(view: HomeVC){
        self.view = view
    }
    // Submit Post service call
    func postServiceCal(imgUrl:String){
        let userDict:NSDictionary = MasterFunctions.sharedInstance.getDictInNSDefaulte(key: "userData") as NSDictionary
        let  userData:UserData = UserData.init(dictionary: userDict)!
        var isCog:Bool =  false
        var sliderValue : Double = self.view.sliderForRatting.sliderValue
        if !self.view.sliderForCogar.isHidden {
            isCog = true
            sliderValue = self.view.sliderForCogar.sliderValue
            
        }
        MasterFunctions.sharedInstance.getAdressFromLatLong(lat: self.view.lat, long: self.view.long, currentAdd: {  (returnAddress,localAdd,state,city) in
            let lines = returnAddress.lines! as [String]
            
            let prm:Parameters  = [
                "imageUrl": imgUrl,
                "sightingType": "NORMAL",
                "rating": sliderValue,
                "isCougar":isCog,
                "userId": userData.id as! Int,
                "timeZone":"Asia/Calcutta",
                "isSelfie":!self.view.isTakenByBackCamera,
                "geo": [
                    "lat": self.view.lat,
                    "lng": self.view.long
                ],
                "location":localAdd,
                "state":state,
                "city":city
            ]
            print(prm)
            MasterWebService.sharedInstance.Call_webServiceUtility(Url: EndPoints.AddPost_URL, useServerRoot: true, prm: prm, auth: true , background: false, methodType: .post, endcodingTyp:JSONEncoding.default , completion: {
                _result,_statusCode in
                print(_result) as! Any
                if _statusCode == 200 {
                    if _result is NSDictionary {
                        print("dict")
                        print(_result)
                        HUD.hide()
                        let Responsedata: NSDictionary = _result as! NSDictionary
                        let resD = Responsedata.value(forKey: "response") as! NSDictionary
                        let status : Int =  resD.value(forKey: "status") as! Int
                        if status == 0 {
                            let message : String = Responsedata.value(forKey: "message") as! String
                            self.view.showErrorToast(message: "\(message)", backgroundColor: UIColor.red)
                        }else  if status == 1 {
                            let message : String = resD.value(forKey: "message") as! String
                            self.view.dismiss(animated: true, completion: nil)
                            self.view.delegate?.didFinishHomeVC(msg: message)
                        }
                    }else
                    {
                        self.view.showErrorToast(message: NSLocalizedString("something_went_wrong_error", comment: ""), backgroundColor: UIColor.red)
                        HUD.hide()
                    }
                }else{
                    self.view.showErrorToast(message: NSLocalizedString("something_went_wrong_error", comment: ""), backgroundColor: UIColor.red)
                    HUD.hide()
                }
            })
        })
        
    }
    
    
    // Hanlde Swip Gesture
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.up {
            print("Swipe Up")
            var slideVal : Double = self.view.sliderForRatting.sliderValue
            if !self.view.sliderForCogar.isHidden {
                slideVal = self.view.sliderForCogar.sliderValue
            }
            if MasterWebService.sharedInstance.Check_networkConnection() {
                if slideVal != 0.0 {
                    if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                        CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
                        self.view.currentLocation = self.view.locManager.location
                        self.view.lat = self.view.currentLocation.coordinate.latitude
                        self.view.long = self.view.currentLocation.coordinate.longitude
                        print(self.view.lat)
                        print(self.view.long)
                        HUD.show(.progress)
                        let img = self.view.imgViewCameraPic.image
                        MasterFunctions.sharedInstance.UploadAWSImageForChatChat(image: img!)
                    }else{
                        self.view.showErrorToast(message: NSLocalizedString("request_to_enable_location_in_device", comment: ""), backgroundColor: UIColor.red)
                    }
                }else{
                    self.view.showErrorToast(message: NSLocalizedString("request_to_provide_rating", comment: ""), backgroundColor: UIColor.red)
                }
            }
        }
        
    }
 }
