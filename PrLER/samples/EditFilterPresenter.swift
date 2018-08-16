//
//  EditFilterPresenter.swift
//  Prowler
//  Created by Dev3 on 8/3/18.
//  Copyright © 2018 dev. All rights reserved.
//

import Foundation
import Alamofire

class EditFilterPresenter{
    let view : EditFilterVc
    var dictset = NSDictionary()
    init(view: EditFilterVc){
        self.view = view
}
    
    //32 GetNotificationSettingApi
    func gEtFilterApi(){
        
        print("CGFloat(self.view.reputabilitySlide.sliderValue) == 0.0: \(CGFloat(self.view.reputabilitySlide.sliderValue))-----self.view.numReputability :\(self.view.numReputability)")
            self.view.numCougarSightings = CGFloat(self.view.sliderForCougar.sliderValue)
            self.view.numVSrating =  CGFloat(self.view.sliderForSight.sliderValue)
            self.view.numNVSrating =  CGFloat(self.view.sliderYelowSignt.sliderValue)
            self.view.numReputability = CGFloat(self.view.reputabilitySlide.sliderValue)
 
        var prm:Parameters = UserDefaults.standard.value(forKey: "mapdata") as! Parameters
        
        print("prm\(prm)")
       
        let prm1:Parameters  = [
            "geoPoint": prm["geoPoint"]!,//1
            "isMap" : prm["isMap"]!,//2
            "pageSize" : prm["pageSize"]!,//3
            "isDraw": prm["isDraw"]!,//4
            "lat": prm["lat"]!,//5
            "lng": prm["lng"]!,//6
            "currentPage" : prm["currentPage"]!,//7
            "searchText": prm["searchText"]!,//8
            "userId" : UserDefaults.standard.value(forKey: "userId") as! Int,//9
            "filter":["reputability" : self.view.numReputability,
                       "type" : self.view.strValueDate,
                       "sightings" : ["isNVS":self.view.blSightSNVS, "NVSrating" : self.view.numNVSrating, "isVS" : self.view.blSightSVS, "VSrating" : self.view.numVSrating],
                       "cougarSightings" : ["type" : self.view.strCougStatus, "rating" : self.view.numCougarSightings],
                        "totalSightings" : self.view.numTotalSightings]
        ]
        
        print("prm1 api: \(prm1)")
        UserDefaults.standard.setValue(prm1, forKey: "filterData")
        UserDefaults.standard.synchronize()
        let imageDataDict:[String: String] = ["image": "filtertrue"]
        
        // post a notification
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationName"), object: nil, userInfo: imageDataDict)
        // `default` is now a property, not a method call
        self.view.navigationController?.popViewController(animated: true)
       
        
    }
    
}
