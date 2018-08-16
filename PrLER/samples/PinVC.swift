//
//  PinVC.swift
//  Prowler
//
//  Created by dev15 on 4/12/18.
//  Copyright © 2018 dev. All rights reserved.
//

import UIKit
import Alamofire

class PinVC: UIViewController,UITextFieldDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var btnForBack: UIButton!
    @IBOutlet weak var imgForVerified: UIImageView!
    
    @IBOutlet weak var imgForBack: UIImageView!
    @IBOutlet weak var btnForResend: UIButton!
    
    @IBOutlet weak var txtFieldForPin: UITextField!
    
    @IBOutlet weak var viewForContainer: UIView!
    
    
    //MARK: LOCAL VARIABLE
    var email:String = ""
    var userName:String = ""
    var soicalId:String = ""
    var accountType:String = ""
    var searchenable : Bool = false
    var Searchtimer: Timer?
    
    lazy var presenter = PinPresenter(view: self)
    
    // MARK: - Life Cycel Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        txtFieldForPin.delegate = self
        self.txtFieldForPin.addTarget(self, action: #selector(PinVC.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.imgForVerified.isHidden = true
        MasterFunctions.sharedInstance.ShowShadow(sender: viewForContainer, color: UIColor(red: 170.0/255, green: 170.0/255, blue: 170.0/255, alpha: 1.0),radius: 10,opacity: 0.80,height: 15)
        txtFieldForPin.layer.cornerRadius = 5.0
        txtFieldForPin.clipsToBounds = true
        txtFieldForPin.layer.borderColor = UIColor.gray.cgColor
        txtFieldForPin.layer.borderWidth = 1
        
        PinVerify().addDiaLogToView(callback: {
            (dict, bool) in
            print(dict ?? "nul", bool ?? "nul")
        })
        
    }
    var isPinValidate:Bool = false
    // MARK: - IB Actions
    
    @IBAction func ActionOnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func ActionOnResendPin(_ sender: UIButton) {
        if btnForResend.titleLabel?.text == "Resend PIN" &&  isPinValidate {
            self.presenter.resend_varification_mail()
        }else if btnForResend.titleLabel?.text == "Activate Account"{
            let homeSearch = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
            self.navigationController?.pushViewController(homeSearch, animated: true)
        }else{
            self.presenter.resend_varification_mail()
        }
        
    }
    
    //MARK: UITextField delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        if newLength > 6 || string == " "
        {
            return false
        }
        return true
    }
    
    //MARK: CUSTOM METHODS
    
    @objc func textFieldDidChange(_ textField:UITextField){
        
        let searchTextString : NSString! = textField.text as NSString!
        if (searchTextString.length  == 6  )
        {
            searchenable = true
            print(textField.text as Any)
            //if (textField.text != ""){
            Searchtimer?.invalidate()
            self.Searchtimer = Timer.scheduledTimer(timeInterval: 0.90, target: self, selector: #selector(PinVC.CallSearch), userInfo: nil, repeats: false)
           }else{
            self.imgForVerified.isHidden = true
            self.btnForResend.setTitle("Resend PIN", for: .normal)
            self.btnForResend.setBackgroundImage(UIImage(named:"Pin_gray_button.png"), for: .normal)//Pin_purpal_button
        }
    }
    
    @objc func CallSearch(){
        Searchtimer?.invalidate()
        if (txtFieldForPin.text != ""){
            self.presenter.PinCheck(SearchText: (txtFieldForPin.text)!)
        }else{
            searchenable = false
        }
        
    }
   
    
}
