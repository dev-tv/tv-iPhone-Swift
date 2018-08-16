  //
  //  EditProfileVC.swift
  //  ProwlereTest
  //
  //  Created by Abhi116 on 05/02/18.
  //  Copyright © 2018 Techvalens. All rights reserved.
  //
  
  import UIKit
  import SDWebImage
  import PKHUD
  import Alamofire
 
  import ActionSheetPicker_3_0
  
  class EditProfileVC: UIViewController,UIActionSheetDelegate {
    //MARK:Local Variable
    var stateArr:[NSDictionary] = []
    var cityArr:[NSDictionary] = []
    var countryId:Int = 0
    var stateId:Int = 0
    var cityId:Int = 0
    var sexualPreId:Int = 0
    var profilePicUrl:String = ""
    var setImage:Bool = false
    var Searchtimer: Timer?
    lazy var presenter = EditProfilePresenter(view: self)
    
    @IBOutlet weak var imgForShadow: UIImageView!
    //MARK: IB-Outlets
    
    @IBOutlet weak var imgForEditUserName: UIImageView!
    @IBOutlet weak var imgForValidateUserName: UIImageView!
    
    
    
    @IBOutlet weak var btnForEditUserName: UIButton!
    
    @IBOutlet weak var btnForProfilePic: UIButton!
    @IBOutlet weak var lableForCity: UILabel!
    @IBOutlet weak var lableForGender: UILabel!
    @IBOutlet weak var lableForSexualPre: UILabel!
    @IBOutlet weak var lableForState: UILabel!
    @IBOutlet weak var lableForCountry: UILabel!
    
    @IBOutlet weak var imgForProPic: UIImageView!
    @IBOutlet weak var viewForContent: UIView!
    
    @IBOutlet weak var btnForEditProfile: UIButton!
    @IBOutlet weak var txtFieldForFirstName: UITextField!
    
    @IBOutlet weak var txtFieldForLastName: UITextField!
    
    @IBOutlet weak var txtFieldForUserName: UITextField!
    
    @IBOutlet weak var txtFieldForEmailId: UITextField!
    
    
    
    @IBOutlet weak var txtFieldForPhoneNumber: UITextField!
    
    
    
    
    @IBOutlet weak var btnForSave: UIButton!
    
    @IBOutlet weak var lblForEditProfile: UILabel!
    
    
    //MARK: Local variable
    var searchenable : Bool = false
    var textForTitle:String = ""
    var textForBtn:String = ""
    var socialDict:NSMutableDictionary = NSMutableDictionary()
    
    
    
    
    //MARK: LyfeCycle methode
    override func viewDidLoad() {
        super.viewDidLoad()
        searchenable = false
        viewForContent.layer.cornerRadius = 8.0
        viewForContent.clipsToBounds = true
        MasterFunctions.sharedInstance.AWSdelegate = self
        txtFieldForUserName.delegate = self
        txtFieldForFirstName.delegate = self
        txtFieldForLastName.delegate = self
        txtFieldForPhoneNumber.delegate = self
        self.txtFieldForUserName.addTarget(self, action: #selector(EditProfileVC.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        if textForTitle != "" {
            self.btnForEditProfile.isHidden = true
            lblForEditProfile.text = textForTitle
            btnForSave.setTitle(textForBtn, for: .normal)
            self.btnForProfilePic.isHidden = true
            let imgUrl = socialDict.value(forKey: "picture") as! String
            let fName = socialDict.value(forKey: "fName") as! String
            let lName = socialDict.value(forKey: "lName") as! String
            let email = socialDict.value(forKey: "email") as! String
            let gender = socialDict.value(forKey: "gender") as! String
            let userName = socialDict.value(forKey: "userName") as! String
            if imgUrl != ""{
                let url = URL.init(string:imgUrl)
                imgForProPic.sd_setImage(with: url , placeholderImage: nil)
                self.imgForProPic.imageCircular()
                //imgForProPic.sd_setImage(with: , completed: )
            }
            if fName != ""{
                txtFieldForFirstName.text = fName
            }
            if lName != ""{
                txtFieldForLastName.text = lName
            }
            if gender != ""{
                lableForGender.text = gender
            }
            if email != ""{
                txtFieldForEmailId.text = email
                txtFieldForEmailId.isUserInteractionEnabled = false
            }
            if userName != ""{
                txtFieldForUserName.text = userName
                self.presenter.UserName_Avaible(SearchText: userName)
                //txtFieldForUserName.isUserInteractionEnabled = false
            }else{
                txtFieldForUserName.isUserInteractionEnabled = true
                 self.imgForValidateUserName.isHidden = true
            }
        }else{
            self.presenter.initView()
        }
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        MasterFunctions.sharedInstance.ShowShadow(sender: viewForContent, color: UIColor(red: 170.0/255, green: 170.0/255, blue: 170.0/255, alpha: 1.0),radius: 10,opacity: 0.80,height: 15)
        MasterFunctions.sharedInstance.ShowShadow(sender: btnForSave, color: UIColor(red: 119.0/255, green: 34.0/255, blue: 206.0/255, alpha: 1.0),radius: 10,opacity: 0.70,height: 7)
        self.presenter.FontSetup()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
          self.imgForProPic.imageCircular()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    
    
    //MARK: IB-Actions
    
    @IBAction func ActionOnProPic(_ sender: Any) {
        self.presenter.openCameraActionSheet()
    }
    
    @IBAction func ActionOnEditProPic(_ sender: UIButton) {
        self.presenter.openCameraActionSheet()
    }
    
    @IBAction func ActionOnSave(_ sender: UIButton) {
        self.presenter.callLocalValidation()
    }
    var sexValue = 0
    @IBAction func actionForSelectSex(_ sender: UIButton) {
        ActionSheetStringPicker.show(withTitle: "Select Sexual Prefrence", rows: EndPoints.sexualPreArr, initialSelection: self.sexValue, doneBlock: {
            picker, value, index in
            self.sexValue = value
            print("value = \(value)")
            //self.sexualPreId = value
            print("index = \(String(describing: index))")
            let dictData:NSDictionary = index as! NSDictionary
            self.lableForSexualPre.text = dictData.value(forKey: "name") as? String
            self.sexualPreId = dictData.value(forKey: "id") as! Int
            self.lableForSexualPre.textColor = UIColor.black
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    var genderValue = 0
    @IBAction func actionForSelectGender(_ sender: UIButton) {
        var DataArray = [[String:Any]]()
        DataArray.append(["name":"Male"])
        DataArray.append(["name":"Female"])
        DataArray.append(["name":"Other"])
        
        let aryLocal:[String] = ["Male","Female","Other"]
        ActionSheetStringPicker.show(withTitle: "Select Gender", rows:DataArray, initialSelection: genderValue, doneBlock: {
            picker, value, index in
            
            self.genderValue = value
            //let dictData:NSDictionary = index as! NSDictionary
            self.lableForGender.text = aryLocal[value]
            self.lableForGender.textColor = UIColor.black
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
        
    }
    
     var countryValue = 0
    @IBAction func ActionOnCountryBtn(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "Select Country", rows: EndPoints.countryArr, initialSelection: countryValue, doneBlock: {
            picker, value, index in
            print("index = \(String(describing: index))")
            let dictData:NSDictionary = index as! NSDictionary
            self.countryValue = value
            self.countryId = dictData.value(forKey: "id") as! Int
            self.lableForCountry.text = dictData.value(forKey: "name") as? String
            self.lableForCountry.textColor = UIColor.black
            self.lableForState.text = "State"
            self.lableForState.textColor = UIColor.lightGray
            self.lableForCity.text = "City"
            self.lableForCity.textColor = UIColor.lightGray
            self.cityId = 0
            self.stateId = 0
            self.presenter.setDropDownsData(url: "api/Countries/\(self.countryId)/states", arrFlag: 0)
             return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
        
        
    }
    
    
     var stateValue = 0
    @IBAction func ActionOnStateBtn(_ sender: Any) {
        if stateArr.count > 0 {
            if countryId != 0 {
                self.lableForCity.text = "City"
                self.lableForCity.textColor = UIColor.lightGray
                self.cityId = 0
                ActionSheetStringPicker.show(withTitle: "Select State", rows: stateArr, initialSelection: stateValue, doneBlock: {
                    picker, value, index in
                    
                    self.stateValue = value
                    let dictData:NSDictionary = index as! NSDictionary
                    self.stateId = dictData.value(forKey: "id") as! Int
                    self.lableForState.text = dictData.value(forKey: "name") as? String
                    self.lableForState.textColor = UIColor.black
                    self.presenter.setDropDownsData(url: "api/States/\(self.stateId)/cities/", arrFlag: 1)
                    return
                }, cancel: { ActionStringCancelBlock in return }, origin: sender)
            }else{
                self.showErrorToast(message: NSLocalizedString("please_select_country_first_error", comment: ""), backgroundColor: .red)
            }
        }else{
            self.showErrorToast(message: NSLocalizedString("please_try_again_later_error", comment: ""), backgroundColor: .gray)
        }
    }
    
    var cityValue = 0
    @IBAction func ActionOnCityBtn(_ sender: Any) {
        if cityArr.count > 0 {
            if stateId != 0 && countryId != 0 {
                ActionSheetStringPicker.show(withTitle: "Select City", rows:cityArr, initialSelection: cityValue, doneBlock: {
                    picker, value, index in
                    self.cityValue = value
                    let dictData:NSDictionary = index as! NSDictionary
                    self.lableForCity.text = dictData.value(forKey: "name") as? String
                    self.cityId = dictData.value(forKey: "id") as! Int
                    self.lableForCity.textColor = UIColor.black
                    return
                }, cancel: { ActionStringCancelBlock in return }, origin: sender)
                
            }else{
                self.showErrorToast(message:NSLocalizedString("please_select_country_and_state_first_error", comment: ""), backgroundColor: .red)
            }
        }else{
            self.showErrorToast(message: NSLocalizedString("please_try_again_later_error", comment: ""), backgroundColor: .gray)
        }
    }
    
    
    
    @IBAction func ActionOnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actionForEditUserName(_ sender: UIButton) {
    }
    
    @objc func CallSearch(){
        Searchtimer?.invalidate()
         let searchTextString : NSString! = txtFieldForUserName.text as NSString!
        if ( searchTextString.length  > 5 && searchTextString.length  < 16 ){
            self.presenter.UserName_Avaible(SearchText: (txtFieldForUserName.text)!)
        }else{
            searchenable = false
        }
    }
    
  }
  
  extension EditProfileVC :MediaAWSUploadDelegate,UITextFieldDelegate  {
    
    
    //MARK: AWS Callback methods
    func MediaAWSUploadFail(){
        //self.Kill_ActivityIndicatore()
        HUD.hide()
        print("AWS uploading Failed !")
        self.showErrorToast(message: NSLocalizedString("server_not_responding_error", comment: ""), backgroundColor: UIColor.red)
    }
    func MediaAWSUploadSuccess(key: String){
        let imgUrl =  EndPoints.ClaudFruntUrl + "/" + key
        print("AWS uploading Successed  !" + imgUrl)
        let firstname = txtFieldForFirstName.text
        let lastname  = txtFieldForLastName.text
        let username  = txtFieldForUserName.text
        let email     = txtFieldForEmailId.text
        let phoneNo  = txtFieldForPhoneNumber.text
        let gender  =  lableForGender.text
        //Condition check for update or register form
        /*if btnForSave.titleLabel?.text == "Sign up" && self.textForTitle != ""  {
         signUp_service(email: email!,  username: username!, firstname: firstname!, lastname:lastname! ,  phoneNo: phoneNo!, profilePic:key )
         }else{*/
        self.presenter.updateUserData(email: email!, username: username!, firstname: firstname!, lastname: lastname!, phoneNo: phoneNo!, profilePic: key, gender: gender! )
        //}
    }
    //MARK: UITextField delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == txtFieldForUserName)
        {
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            
            
            if newLength > 15 || string == " "
            {
                return false
            }
            return true
        }
        
        if(textField == txtFieldForFirstName)
        {
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            
            if newLength > 25
            {
                return false
            }
            return true
        }
        if(textField == txtFieldForLastName)
        {
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            
            if newLength > 25
            {
                return false
            }
            return true
        }
        if(textField == txtFieldForPhoneNumber)
        {
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            
            if newLength > 12
            {
                return false
            }
            return true
        }
        
        return true
        
    }
    
    @objc func textFieldDidChange(_ textField:UITextField){
        
        let searchTextString : NSString! = textField.text as NSString!
        if (searchTextString.length  > 5 && searchTextString.length  < 16 )
        {
            searchenable = true
            print(textField.text as Any)
            Searchtimer?.invalidate()
            self.Searchtimer = Timer.scheduledTimer(timeInterval: 0.90, target: self, selector: #selector(EditProfileVC.CallSearch), userInfo: nil, repeats: false)
        }else{
            self.imgForValidateUserName.isHidden = true
        }
    }
    
  }
