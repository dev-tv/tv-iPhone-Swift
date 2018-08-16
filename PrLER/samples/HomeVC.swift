//
//  HomeVC.swift
//  Prowler
//
//  Created by Dev4 on 2/14/18.
//  Copyright © 2018 dev. All rights reserved.
//

import UIKit
import PKHUD
import MapKit

protocol HomeVCDelegate {
    func didFinishHomeVC(msg: String)
}


class HomeVC: UIViewController{
    let device : Model = UIDevice().type
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    var lat :Double = 0.0
    var long:Double = 0.0
    lazy var presenter = HomePresenter(view: self)
    @IBOutlet weak var vwFloatLbl: UIView!
    // MARK: iB-Outlets
    @IBOutlet weak var viewForSwipGesture: UIView!
    @IBOutlet weak var imgForSwipeUp: UIImageView!
    @IBOutlet weak var lableForSwipUp: UILabel!
    @IBOutlet weak var sliderForRatting: ProwlerSlider!
    @IBOutlet weak var imgViewCameraPic: UIImageView!
    @IBOutlet weak var sliderForCogar: ProwlerSlider!
    @IBOutlet weak var btnForCougar: UIButton!
    @IBOutlet weak var btnForCamera: UIButton!
    var imgFromCamera:UIImage = UIImage()
    var isTakenByBackCamera:Bool = false
    var delegate: HomeVCDelegate?
    
    //MARK: Life Cycel Method
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeUp = UISwipeGestureRecognizer(target: self.presenter, action: #selector(self.presenter.handleGesture))
        swipeUp.direction = .up
        self.viewForSwipGesture.addGestureRecognizer(swipeUp)
        imgViewCameraPic.image = imgFromCamera
        MasterFunctions.sharedInstance.AWSdelegate = self
        vwFloatLbl.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sliderForCogar.InitialSetup(typeOf: 1)
        sliderForRatting.InitialSetup(typeOf: 2)
        
        self.vwFloatLbl.frame.origin.y = self.view.frame.size.height/2
        
        UIView.animate(withDuration: 0.5, delay: 0.9, options: [.repeat, .autoreverse], animations: {
            
            var vwTopFrame =  self.vwFloatLbl.frame
            vwTopFrame.origin.y -= vwTopFrame.height + 10
            self.vwFloatLbl.frame = vwTopFrame
            
            
            
//            var imgTopFrame = self.imgForSwipeUp.frame
//            imgTopFrame.origin.y -= imgTopFrame.height + 10
//            self.imgForSwipeUp.frame = imgTopFrame
//            var lblTopFrame =  self.lableForSwipUp.frame
//            lblTopFrame.origin.y -= imgTopFrame.height + 10
//            self.lableForSwipUp.frame = lblTopFrame
        }, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: iB-Actions
    
    @IBAction func ActionOnBtnRetake(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        // self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func ActionOnBtnCougar(_ sender: Any) {
        btnForCougar.isSelected =  btnForCougar.isSelected ? false : true
        sliderForCogar.isHidden =  sliderForCogar.isHidden ? false : true
        sliderForRatting.isHidden =  sliderForCogar.isHidden ? false : true
    }
    
 }




extension HomeVC:MediaAWSUploadDelegate{
    //MARK: AWS Delegate methods
    func MediaAWSUploadFail() {
        HUD.hide()
        print("AWS uploading Failed !")
        self.showErrorToast(message: NSLocalizedString("server_not_responding_error", comment: ""), backgroundColor: UIColor.red)
    }
    
    func MediaAWSUploadSuccess(key: String) {
        let imgUrl =  EndPoints.ClaudFruntUrl + "/" + key
        print("AWS uploading Successed  !" + imgUrl)
        self.presenter.postServiceCal(imgUrl:key)
    }
}
