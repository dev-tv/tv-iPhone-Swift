//
//  SettingVC.swift
//  Analog Clock
//
//  Created by dev5 on 2/26/18.
//  Copyright © 2018 techvalens LLC. All rights reserved.
//
import UIKit

class SettingVC: UIViewController,UITableViewDelegate,UITableViewDataSource,MyAlertProtocol {
    
    //#MARK:- Preparing the IBOutlet of component
    @IBOutlet weak var imgViewForHome: UIImageView!
    @IBOutlet weak var bgForSettings: UIImageView!
    @IBOutlet weak var titleForSetting: UILabel!
    @IBOutlet weak var btnForHomeButton: UIButton!
    @IBOutlet weak var tblViewForSetting: UITableView!
    var menuText: [String] = ["BACKGROUND","WATCH CUSTOMIZATION","EVENT FONT","ALERT TIME","THEME"]
    @IBOutlet weak var lblForNavigationBottom: UILabel!
    var strForAlertNotify: String?
    
    //#MARK:- Application life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tblViewForSetting.delegate = self
        tblViewForSetting.dataSource = self
        tblViewForSetting.register(UINib(nibName: "SettingCell", bundle: nil), forCellReuseIdentifier: "SettingCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.getBackgroundSettings()
        self.getvalueFromAlert()
    }
    
    //#MARK:- update alert notification
    func getvalueFromAlert(){
        if let getAlertStr = UserDefaults.standard.string(forKey: "savedAlert") {
        strForAlertNotify = getAlertStr
        }else{
            strForAlertNotify = "None"
        }
        tblViewForSetting.reloadData()
    }
    
    //#MARK:- update background settings
    func getBackgroundSettings(){
        bgForSettings.image = UIImage(named:setBackGroundTheme)
        imgViewForHome.image = UIImage(named: home)
        titleForSetting.textColor = textColor.textColor
        lblForNavigationBottom.backgroundColor = textColor.textColor
    }
    
    func setResultOfBusinessLogic(valueSent: String) {
        strForAlertNotify = valueSent
    }
    
    //#MARK:- delegate and datasource of table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuText.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblViewForSetting.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell
        
        if indexPath.row == 4{
            if UserDefaults.standard.bool(forKey: "daynight") == true{
                cell.imgViewForNightOff.image = UIImage(named: "night_on")
                cell.imgViewForDayOn.image = UIImage(named: "day_off")
            }else{
                cell.imgViewForNightOff.image = UIImage(named: "night_off")
                cell.imgViewForDayOn.image = UIImage(named: "day_on")
            }
            cell.imgViewForNextScreen.isHidden = true
            cell.btnForDayOn.isHidden = false
            cell.btnForNightOff.isHidden = false
            cell.lblForDay.isHidden = false
            cell.lblForNight.isHidden = false
            cell.btnForDayOn.addTarget(self, action: #selector(SettingVC.ActionOnDayOn(sender:)), for: .touchUpInside)
            cell.btnForNightOff.addTarget(self, action: #selector(SettingVC.ActionOnNightOff(sender:)), for: .touchUpInside)
            cell.btnForNextScreen.isHidden = true
            cell.btnForSettingCell.isHidden = true
            cell.lblForAlertNotification.isHidden = true
        }else if indexPath.row == 3{
            cell.lblForAlertNotification.text = strForAlertNotify
            cell.lblForAlertNotification.isHidden = false
            cell.imgViewForNextScreen.isHidden = false
            cell.imgViewForDayOn.isHidden = true
            cell.imgViewForNightOff.isHidden = true
            cell.btnForDayOn.isHidden = true
            cell.btnForNightOff.isHidden = true
            cell.btnForNextScreen.isHidden = false
            cell.lblForDay.isHidden = true
            cell.lblForNight.isHidden = true
            cell.btnForNextScreen.addTarget(self, action: #selector(SettingVC.ActionOnNextScreen(sender:)), for: .touchUpInside)
        }
        else{
            cell.lblForAlertNotification.isHidden = true
            cell.imgViewForNextScreen.isHidden = false
            cell.imgViewForDayOn.isHidden = true
            cell.imgViewForNightOff.isHidden = true
            cell.btnForDayOn.isHidden = true
            cell.btnForNightOff.isHidden = true
            cell.btnForNextScreen.isHidden = false
            cell.lblForDay.isHidden = true
            cell.lblForNight.isHidden = true
            cell.btnForNextScreen.addTarget(self, action: #selector(SettingVC.ActionOnNextScreen(sender:)), for: .touchUpInside)
        }
        cell.lblForSettingOption.text = menuText[indexPath.row]
        cell.lblForSettingOption.textColor = textColor.textColor
        cell.btnForSettingCell.addTarget(self, action: #selector(SettingVC.ActionOnSettingCell(sender:)), for: .touchUpInside)
        cell.btnForSettingCell.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    @objc func ActionOnNextScreen(sender: UIButton){
    }
    
    //#MARK:- action on DayOn
    @objc func ActionOnDayOn(sender: UIButton){
        UserDefaults.standard.set(false, forKey: "daynight")
        var myTextIcons = MyTextIcons()
        myTextIcons.setTheme()
        bgForSettings.image = UIImage(named: setBackGroundTheme)
        titleForSetting.textColor = textColor.textColor
        imgViewForHome.image = UIImage(named: home)
        lblForNavigationBottom.backgroundColor = textColor.textColor
        tblViewForSetting.reloadData()
    }
    
    //#MARK:- action on Night Off
    @objc func ActionOnNightOff(sender: UIButton){
        UserDefaults.standard.set(true, forKey: "daynight")
        var myTextIcons = MyTextIcons()
        myTextIcons.setTheme()
        bgForSettings.image = UIImage(named: setBackGroundTheme)
        titleForSetting.textColor = textColor.textColor
        imgViewForHome.image = UIImage(named: home)
        lblForNavigationBottom.backgroundColor = textColor.textColor
        tblViewForSetting.reloadData()
    }
    
    //#MARK:- action on Setting cell
    @objc func ActionOnSettingCell(sender: UIButton){
        let tbIndex = sender.tag
        if tbIndex == 0{
            let backGround = self.storyboard?.instantiateViewController(withIdentifier: "BackgroundVC") as? BackgroundVC
            self.navigationController?.pushViewController(backGround!, animated: true)
        }else if tbIndex == 1{
            let watchCustomization = self.storyboard?.instantiateViewController(withIdentifier: "WatchCustomizationVc") as? WatchCustomizationVc
            self.navigationController?.pushViewController(watchCustomization!, animated: true)
        }else if tbIndex == 2{
            let fonts = self.storyboard?.instantiateViewController(withIdentifier: "FontsVC") as? FontsVC
            self.navigationController?.pushViewController(fonts!, animated: true)
        }else if tbIndex == 3{
            let alertVC = self.storyboard?.instantiateViewController(withIdentifier: "AlertTimeVC")as! AlertTimeVC
            alertVC.delegate = self
            self.navigationController?.pushViewController(alertVC, animated: true)
        } else{
            print("Empty Class")
        }
    }
    
    //#MARK:- action on Home button
    @IBAction func actionOnHomeButton(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.navigationController?.popViewController(animated: false)
    }
}
