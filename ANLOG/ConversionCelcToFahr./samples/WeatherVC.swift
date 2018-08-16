
import UIKit
import CoreLocation
import SwiftGifOrigin



class WeatherVC: UIViewController,CLLocationManagerDelegate {
    
    //MARK:- Preparing the IBOutlet of uicomponent
    @IBOutlet weak var bgForWeather: UIImageView!
    @IBOutlet weak var tblWeather: UITableView!
    var strIsCommingFrom: String = String()
    var strForCityName: String = ""
    var List_Array : [List] = []
    var Response_Aeris_Forecast = [Response]()
    var Response_Aeris_Current = [Response]()
    var Response_PhaseMoon = [MoonResponse]()
    var Home_Aeris_MaxMinTemp = [TempResponse]()
    @IBOutlet weak var mainViewForGpsOnOff: UIView!
    @IBOutlet weak var viewForGpsOnOff: UIView!
    @IBOutlet weak var lblForGpsOnOffMessage: UILabel!
    @IBOutlet weak var btnForAllowAccess: UIButton!
    let locationManager = CLLocationManager()
    let reachability = Reach()
    var isCurrentLocatin: Bool = false
    @IBOutlet weak var titleForWeather: UILabel!
    @IBOutlet weak var imgViewForBack: UIImageView!
    @IBOutlet weak var imgViewForPlace: UIImageView!
    @IBOutlet weak var lblForTopBottomLine: UILabel!
    
  
   
    
     //MARK:- Application Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        reachability.monitorReachabilityChanges()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        self.setUpForCustomCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.Response_PhaseMoon.removeAll()
        self.addObserver()
        self.setUpView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.removeObserver()
    }

     //MARK:- set addobserver
    func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
    }
    
     //MARK:- set remove observer
    func removeObserver(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
    }
    
     //MARK:- setUpView
    func setUpView(){
       setUpBackgroundAndText()
        locationManager.requestAlwaysAuthorization()
        if currentWeatherstring != ""   {
            if MasterWebService.sharedInstance.Check_networkConnection(){
                self.setViewForConnectionNetwork()
                self.maxAndMinWeatherApi()
                self.ForecastWeatherApi()
                self.CurrentForecastWeatherApi()
                self.Aeris_PhaseMoon_service(isCallInBG: false)
                tblWeather.delegate = self
                tblWeather.dataSource = self
                tblWeather.reloadData()
            }else{
                self.setViewForNoNetworkConnection()
            }
        }else if checkLocationEnableDisable() {
            if MasterWebService.sharedInstance.Check_networkConnection(){
                self.setViewForConnectionNetwork()
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            }else{
                self.setViewForNoNetworkConnection()
            }
        }else{
            self.setViewForDisabledLocation()
        }
    }
    
    //MARK:- setUpBackgroundAndText
    func setUpBackgroundAndText(){
        bgForWeather.image = UIImage(named:setBackGroundTheme)
        titleForWeather.textColor = textColorLbl.textColor
        imgViewForBack.image = UIImage(named: back)
        imgViewForPlace.image = UIImage(named: place)
        lblForTopBottomLine.backgroundColor = textColorLbl.textColor
        }

    //MARK:- setUpViewForNetwork connection
    func setViewForNoNetworkConnection(){
        tblWeather.isHidden = true
        mainViewForGpsOnOff.isHidden = false
        self.view.bringSubview(toFront: mainViewForGpsOnOff)
        lblForGpsOnOffMessage.text = "No network connection available to provide your local forecast"
        btnForAllowAccess.isHidden = true
    }
    
    //MARK:- setUpViewForNetwork connection
    func setViewForConnectionNetwork(){
        tblWeather.isHidden = false
        self.view.bringSubview(toFront: tblWeather)
        mainViewForGpsOnOff.isHidden = true
        self.view.bringSubview(toFront: tblWeather)
    }
    
    //MARK:- setUpViewFor location disable
    func setViewForDisabledLocation(){
        lblForGpsOnOffMessage.text = "Weather needs to access your location to provide your local forecast"
        lblForGpsOnOffMessage.textColor = textColorLbl.textColor
        btnForAllowAccess.isHidden = false
        tblWeather.isHidden = true
        mainViewForGpsOnOff.isHidden = false
    }
    //MARK:- show network connction
    func showErrorForNoNetwork(){
        self.showErrorToast(message: "No Network Connection Available, Please Try Again Later.", backgroundColor: .red)
    }
    
    //MARK:- reachabilityChanged
    @objc func reachabilityChanged(){
        self.setUpView()
    }
    
    //MARK:- will enter background
    @objc func willEnterForeground() {
        self.setUpView()
    }
    
     //MARK:- checkLocationEnableDisable
    func checkLocationEnableDisable() -> Bool{
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            }
        } else {
            return false
        }
    }
    
    //MARK:- didUpdateLocations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        currentlatitude = locValue.latitude
        currentlongitude = locValue.longitude
        print("\(currentlatitude)","\(currentlongitude)")
        locationManager.stopUpdatingLocation()
        if !isCurrentLocatin {
            getLocationFromLatLong()
        }
    }
    
    //MARK:- didChangeAuthorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.setUpView()
    }
    //MARK: get place info from current lat long
    func getLocationFromLatLong(){
        isCurrentLocatin = true
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: currentlatitude, longitude: currentlongitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            if placeMark.addressDictionary != nil {
                print(placeMark)
                let country : String = placeMark.isoCountryCode!
                let cityname : String = placeMark.subAdministrativeArea!
                print("city name >>>>",cityname,"country code>>>",country)
                currentWeatherstring = cityname.lowercased() + "," + country.lowercased()
                currentCityName = cityname
                self.maxAndMinWeatherApi()
                self.ForecastWeatherApi()
                self.Aeris_PhaseMoon_service(isCallInBG: false)
                //self.Aeris_Weather_service(isCallInBG: false)
                self.isCurrentLocatin = false
            }
        })
    }
    
    //MARK: setUpForCustomCell
    func setUpForCustomCell(){
        let tblCell = UINib(nibName: "TempratureCell", bundle: nil)
        tblWeather.register(tblCell, forCellReuseIdentifier: "TempratureCell")
        let tbl_week_Cell = UINib(nibName:"WeekWeatherCell", bundle: nil)
        tblWeather.register(tbl_week_Cell, forCellReuseIdentifier: "WeekWeatherCell")
        let tbl_HumidityCell = UINib(nibName:"HumidityCell", bundle: nil)
        tblWeather.register(tbl_HumidityCell, forCellReuseIdentifier: "HumidityCell")
        let tbl_WindCellCell = UINib(nibName:"WindCell", bundle: nil)
        tblWeather.register(tbl_WindCellCell, forCellReuseIdentifier: "WindCell")
        let tbl_DayUpdateCell = UINib(nibName:"DayUpdateCell", bundle: nil)
        tblWeather.register(tbl_DayUpdateCell, forCellReuseIdentifier: "DayUpdateCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: service for open weather service
    func Open_Weather_service(isCallInBG:Bool){
        MasterWebService.sharedInstance.GET_webservice(Url: EndPoints.Ope_Weather_URL + "?id=\(city_id)&APPID=\(AppId)" , background: isCallInBG, completion: {_result,_statusCode in
            print(_result)
            print(_statusCode!)
            if _statusCode == 200{
                if _result is NSDictionary{
                    print(_result)
                    let responseData: NSDictionary = _result as! NSDictionary
                    let openWeathModel: OpenWeatherModel = OpenWeatherModel.init(dictionary: responseData)!
                    print(openWeathModel.cod!)
                    print(openWeathModel.message!)
                    self.List_Array = openWeathModel.list!
                    print(openWeathModel.list![0].dt!)
                    print(openWeathModel.city!.coord!.lat!)
                    print(openWeathModel.cnt!)
                }
            }else
            {
                self.showErrorToast(message: "Somthing went wrong JSON serialization failed.", backgroundColor: UIColor.red)
            }
        })
        
    }
    
     //MARK:call the Aeris_Weather_service
    func Aeris_Weather_service(isCallInBG:Bool){
        BackenedUtility.Aeris_Weather_API(isCallInBG: isCallInBG, completion:
            {_result,_statusCode in
                print(_result)
                print(_statusCode!)
                if _statusCode == 200{
                    if _result is NSDictionary{
                        print(_result)
                        let responsData: NSDictionary = _result as! NSDictionary
                        let aerisWeatherModel:Aeris_Update_Weather = Aeris_Update_Weather.init(dictionary: responsData)!
                       // self.Response_Aeris = aerisWeatherModel.response!
                        self.tblWeather.reloadData()
                    }
                }else
                {
                    self.showErrorToast(message: "Somthing went wrong JSON serialization failed.", backgroundColor: UIColor.red)
                }
        })
    }
   
      //MARK:service call for aeris phase moon...
    func Aeris_PhaseMoon_service(isCallInBG:Bool){
        
        BackenedUtility.Aeris_PhaseMoon_API(isCallInBG: isCallInBG, completion: {_result,_statusCode in
            print(_result)
            print(_statusCode!)
            if _statusCode == 200{
                if _result is NSDictionary{
                    print(_result)
                    let responsData: NSDictionary = _result as! NSDictionary
                    let aerisMoonPhaseModel:Aeris_PhaseMoon_Model = Aeris_PhaseMoon_Model.init(dictionary: responsData)!
                    self.Response_PhaseMoon = aerisMoonPhaseModel.response!
                    self.tblWeather.reloadData()
                }
            }else
            {
                self.showErrorToast(message: "Somthing went wrong JSON serialization failed.", backgroundColor: UIColor.red)
            }
        })
    }
    
     //MARK:service call for ForecastWeatherApi...
    func ForecastWeatherApi(){
        BackenedUtility.Aeris_Weather_APIFor_Forecast(isCallInBG: false, completion: {_result,_statusCode in
            print(_result)
            print(_statusCode!)
            if _statusCode == 200{
                if _result is NSDictionary{
                    print(_result)
                    let responsData: NSDictionary = _result as! NSDictionary
                    let aerisWeatherModel:Aeris_Update_Weather = Aeris_Update_Weather.init(dictionary: responsData)!
                    self.Response_Aeris_Forecast = aerisWeatherModel.response!
                    self.tblWeather.reloadData()
                }
            }else
            {
                self.showErrorToast(message: "Somthing went wrong JSON serialization failed.", backgroundColor: UIColor.red)
            }
        })
    }
    
    
    //MARK:- Weathet API for Max and Min Temp.....
    func maxAndMinWeatherApi(){
        BackenedUtility.Aeris_Weather_APIFor_MaxMinTemp(isCallInBG: false, completion: {_result,_statusCode in
            print(_result)
            print(_statusCode!)
            if _statusCode == 200{
                if _result is NSDictionary{
                    print(_result)
                    let responsData: NSDictionary = _result as! NSDictionary
                    let aerisWeatherTemp:MaxMinTempModel = MaxMinTempModel.init(dictionary: responsData)!
                    print(aerisWeatherTemp.response![0].periods![0].maxTempC!)
                    self.Home_Aeris_MaxMinTemp = aerisWeatherTemp.response!
                    print(self.Home_Aeris_MaxMinTemp[0].periods![0].maxTempC!)
                    self.tblWeather.reloadData()
                }
            }else
            {
                self.showErrorToast(message: "Somthing went wrong JSON serialization failed.", backgroundColor: UIColor.red)
            }
        })
    }
    
 //MARK:service call for CurrentForecastWeatherApi...
    func CurrentForecastWeatherApi(){
        BackenedUtility.Aeris_Weather_APIFor_CurrentForecast(isCallInBG: false, completion: {_result,_statusCode in
            print(_result)
            print(_statusCode!)
            if _statusCode == 200{
                if _result is NSDictionary{
                    print(_result)
                    let responsData: NSDictionary = _result as! NSDictionary
                    let aerisWeatherModel:Aeris_Update_Weather = Aeris_Update_Weather.init(dictionary: responsData)!
                    self.Response_Aeris_Current = aerisWeatherModel.response!
                    self.tblWeather.reloadData()
                    
                }
            }else
            {
                self.showErrorToast(message: "Somthing went wrong JSON serialization failed.", backgroundColor: UIColor.red)
            }
        })
        
    }
    
    //MARK:action on manage cities...
    @IBAction func actionOnManageCitiesTapped(_ sender: UIButton) {
        strIsCommingFrom = "WeatherVC"
        let manageCities = self.storyboard?.instantiateViewController(withIdentifier: "ManageCitiesVC") as! ManageCitiesVC
        manageCities.strIsCommingFrom = strIsCommingFrom
        self.navigationController?.pushViewController(manageCities, animated: true)
    }
    
    //MARK:action on back button...
    @IBAction func actionOnBackButton(_ sender: UIButton) {
        strIsCommingFrom = "WeatherVC"
        for vc in self.navigationController!.viewControllers {
            if let myHomeVc = vc as? HomeVC {
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromTop
                view.window!.layer.add(transition, forKey: kCATransition)
                self.navigationController?.popToViewController(myHomeVc, animated: false)
            }
        }
    }
    
    //MARK:action on edit...
    @objc func ActionOnEdit(sender: UIButton){
        if MasterWebService.sharedInstance.Check_networkConnection(){
            let index = sender.tag
            if index == 0 {
                WeatherPopup().addDiaLogToView(popType: true, callback:{dict,boolean in
                    if boolean! {
                        self.tblWeather.reloadData()
                    }
                })
            }else {
                WeatherPopup().addDiaLogToView(popType: false, callback:{dict,boolean in
                    if boolean! {
                        self.tblWeather.reloadData()
                    }
                })
            }
        }else{
            self.showErrorForNoNetwork()
        }
    }
    
    //MARK:action on actionForOnOffGps...
    @IBAction func actionForOnOffGps(_ sender: UIButton) {
        if !CLLocationManager.locationServicesEnabled() {
            if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") {
                UIApplication.shared.openURL(url)
            }
        } else {
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
   //MARK:action on getCurrentDay...
    func getCurrentDay() ->String{
        let formatter = DateFormatter.init()
        formatter.dateFormat = "EEEE"
        let namedate = Date.init() //or any date
        let dayName = formatter.string(from: namedate)
        print(dayName)
        let todayDay = dayName.uppercased()
        return todayDay
    }
    
    //MARK:action on getCurrentDate...
    func getCurrentDate(dateStyle: Double) ->String{
        let date = Date(timeIntervalSince1970: dateStyle)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd-MM-yyyy "
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    
    //MARK:- Epoch & Unix Timestamp Conversion Tools
    func getCurrentRiseSetTime(dateStyle:Double) -> String{
        let sunRiseTime = Date(timeIntervalSince1970: dateStyle)
        let dateFormatter1 = DateFormatter()
         dateFormatter1.timeZone = TimeZone(abbreviation: currentTimeZone)
        dateFormatter1.dateFormat = "hh:mm a"
        let sunRise = dateFormatter1.string(from: sunRiseTime)
        print(sunRise)
        return sunRise
    }
    
   
    func getTimeZoneFromLatLong(setLat: Double, setLOng: Double,handler:@escaping ((String)->Void)){
        let location : CLLocation = CLLocation(latitude: CLLocationDegrees(setLat), longitude:  CLLocationDegrees(setLOng))
        let Gcode : CLGeocoder = CLGeocoder()
        var getTimeZone: String = ""
        Gcode.reverseGeocodeLocation(location, completionHandler: { array, error in
            let placmark:CLPlacemark = array![0]
            if let accessZone = placmark.timeZone{
                getTimeZone = (accessZone.abbreviation())!
                print(array?.description)
                print(placmark.timeZone)
                currentTimeZoneIdentifier = (placmark.timeZone?.identifier)!
                print(currentTimeZoneIdentifier)
                handler(getTimeZone)
            }
        })
    }
}


func getCurrentTimeResult()-> String{
    let date2 = NSDate()
    var calendar = NSCalendar.current
    print(calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date2 as! Date))
    let unitFlags = Set<Calendar.Component>([.hour, .year, .minute])
    calendar.timeZone = TimeZone(identifier: currentTimeZoneIdentifier)!
    let components = calendar.dateComponents(unitFlags, from: date2 as! Date)
    let hour = calendar.component(.hour, from: date2 as! Date)
    let minutes = calendar.component(.minute, from: date2 as! Date)
    let seconds = calendar.component(.second, from: date2 as! Date)
    var dayNightStatus: String = ""
    var currentTimeShow: String = ""
    var hourTime: String = ""
    var minTime : String = ""
    if hour > 1 && hour < 12 {
        dayNightStatus = "AM"
        if minutes >= 1 && minutes < 10{
            minTime = "0" + String(minutes)
        }else{
            minTime = String(minutes)
        }
        if hour >= 1 && hour < 10{
            hourTime = "0" + String(hour)
        }else{
            hourTime = String(hour)
        }
        currentTimeShow = hourTime + ":" + minTime + " " + dayNightStatus
    }else if hour == 12 {
        dayNightStatus = "PM"
        if minutes >= 1 && minutes < 10{
            minTime = "0" + String(minutes)
        }else{
            minTime = String(minutes)
        }
        currentTimeShow = String(hour) + ":" + minTime + " " + dayNightStatus
        
    }else if hour > 12 && hour <= 24{
        dayNightStatus = "PM"
        
        if minutes >= 1 && minutes < 10{
            minTime = "0" + String(minutes)
        }else{
            minTime = String(minutes)
        }
        if (hour - 12) >= 1 && (hour - 12) < 10{
            hourTime = "0" + String((hour - 12))
        }else{
            hourTime = String(hour)
        }
        currentTimeShow = hourTime + ":" + minTime + " " + dayNightStatus
    }else{
         currentTimeShow = "00" + ":" + "00" + "NO"
    }
    return currentTimeShow
    
}

  //MARK:extensuio use for table view...
extension WeatherVC: UITableViewDelegate, UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell: TempratureCell = tableView.dequeueReusableCell(withIdentifier: "TempratureCell", for: indexPath) as! TempratureCell
            if self.Response_Aeris_Current.count != 0{
                let todayDays = self.getCurrentDay()
                cell.lblForDayName.text = todayDays
                if strIsCommingFrom == "HomeVC"{
                    cell.lblForCityName.text = strForCityName.uppercased()
                }else{
                    cell.lblForCityName.text = currentCityName.uppercased()
                }
                let myIntValue:Int = self.Response_Aeris_Current[0].periods![0].avgTempC!
                let myIntFarenHeight1:Int = self.Response_Aeris_Current[0].periods![0].avgTempF!
                
                if  UserDefaults.standard.bool(forKey: "Centigrade") != false{
                    cell.lblForCityTemperature.text = String(myIntValue) + "°" + "C"
                }else if UserDefaults.standard.bool(forKey: "Fahrenheit") != false{
                    cell.lblForCityTemperature.text = String(myIntFarenHeight1) + "°" + "F"
                }else{
                     cell.lblForCityTemperature.text = String(myIntValue) + "°" + "C"
                }
                
                let dateStyle : Double = Double(self.Response_Aeris_Current[0].periods![0].timestamp!)
                let currentDate = self.getCurrentDate(dateStyle: dateStyle)
                cell.lblForDate.text = currentDate
                
                if let upTemp = self.Home_Aeris_MaxMinTemp[0].periods![0].maxTempC{
                    cell.lblForUpTemperature.text = String(upTemp)
                }
                
                if let downTemp = self.Home_Aeris_MaxMinTemp[0].periods![0].minTempC{
                    cell.lblForDownTemperature.text = String(downTemp)
                }
                
                let cloudStatus = self.Response_Aeris_Current[0].periods![0].cloudsCoded!
                let cloudLevel = self.Response_Aeris_Current[0].periods![0].weather!
                cell.lblForPartlyCloud.text = cloudLevel
                let cloudSta = cloudStatus
                switch cloudSta {
                case "SC":
                    cell.imgViewForCloudStatus.image = UIImage(named:cloud1)
                case "CL":
                    cell.imgViewForCloudStatus.image = UIImage(named:cloud2)
                case "FW":
                    cell.imgViewForCloudStatus.image = UIImage(named:cloud1)
                case "BK":
                    cell.imgViewForCloudStatus.image = UIImage(named:cloud3)
                case "OV":
                    cell.imgViewForCloudStatus.image = UIImage(named:cloud3)
                default:
                    cell.imgViewForCloudStatus.image = UIImage(named:cloud2)
                }
            }
            cell.btnForTempFahren.tag = indexPath.row
            cell.btnForTempFahren.addTarget(self, action: #selector(WeatherVC.ActionOnEdit(sender:)), for: .touchUpInside)
            return cell
        }else if indexPath.row == 1 {
            let cell2 : WeekWeatherCell  = tableView.dequeueReusableCell(withIdentifier: "WeekWeatherCell", for: indexPath) as! WeekWeatherCell
            let todayDays = self.getCurrentDay()
            let Day = todayDays
            switch Day {
            case "THURSDAY":
                cell2.lblForFirstDay.text = "FRI"
                cell2.lblForSecondDay.text = "SAT"
                cell2.lblForThirdDay.text = "SUN"
                cell2.lblForFourthDay.text = "MON"
                cell2.lblForFifthDay.text = "TUE"
                cell2.lblForSixthDay.text = "WED"
            case "FRIDAY":
                cell2.lblForFirstDay.text = "SAT"
                cell2.lblForSecondDay.text = "SUN"
                cell2.lblForThirdDay.text = "MON"
                cell2.lblForFourthDay.text = "TUE"
                cell2.lblForFifthDay.text = "WED"
                cell2.lblForSixthDay.text = "THU"
            case "SATURDAY":
                cell2.lblForFirstDay.text = "SUN"
                cell2.lblForSecondDay.text = "MON"
                cell2.lblForThirdDay.text = "TUE"
                cell2.lblForFourthDay.text = "WED"
                cell2.lblForFifthDay.text = "THU"
                cell2.lblForSixthDay.text = "FRI"
            case "SUNDAY":
                cell2.lblForFirstDay.text = "MON"
                cell2.lblForSecondDay.text = "TUE"
                cell2.lblForThirdDay.text = "WED"
                cell2.lblForFourthDay.text = "THU"
                cell2.lblForFifthDay.text = "FRI"
                cell2.lblForSixthDay.text = "SAT"
            case "MONDAY":
                cell2.lblForFirstDay.text = "TUE"
                cell2.lblForSecondDay.text = "WED"
                cell2.lblForThirdDay.text = "THU"
                cell2.lblForFourthDay.text = "FRI"
                cell2.lblForFifthDay.text = "SAT"
                cell2.lblForSixthDay.text = "SUN"
            case "TUESDAY":
                cell2.lblForFirstDay.text = "WED"
                cell2.lblForSecondDay.text = "THU"
                cell2.lblForThirdDay.text = "FRI"
                cell2.lblForFourthDay.text = "SAT"
                cell2.lblForFifthDay.text = "SUN"
                cell2.lblForSixthDay.text = "MON"
            case "WEDNESDAY":
                cell2.lblForFirstDay.text = "THU"
                cell2.lblForSecondDay.text = "FRI"
                cell2.lblForThirdDay.text = "SAT"
                cell2.lblForFourthDay.text = "SUN"
                cell2.lblForFifthDay.text = "MON"
                cell2.lblForSixthDay.text = "TUE"
            default:
                print("No Day Here")
            }

            if self.Response_Aeris_Forecast.count != 0 {
                if indexPath.row == 1{
                    let avgTemp1: Int = self.Response_Aeris_Forecast[0].periods![1].avgTempC!
                    cell2.lblForFirstTemp.text = String(avgTemp1) + "°" 
                    let avgTemp2: Int = self.Response_Aeris_Forecast[0].periods![2].avgTempC!
                    cell2.lblForSecondTemp.text = String(avgTemp2) + "°"
                    let avgTemp3: Int = self.Response_Aeris_Forecast[0].periods![3].avgTempC!
                    cell2.lblForThirdTemp.text = String(avgTemp3) + "°"
                    let avgTemp4: Int = self.Response_Aeris_Forecast[0].periods![4].avgTempC!
                    cell2.lblForFourthTemp.text = String(avgTemp4) + "°"
                    let avgTemp5: Int = self.Response_Aeris_Forecast[0].periods![5].avgTempC!
                    cell2.lblForFiveTemp.text = String(avgTemp5) + "°"
                    let avgTemp6: Int = self.Response_Aeris_Forecast[0].periods![6].avgTempC!
                    cell2.lblForSixTemp.text = String(avgTemp6) + "°"
                    let cloudStatus1: String = self.Response_Aeris_Forecast[0].periods![1].cloudsCoded!
                    let cloudSta1 = cloudStatus1
                    switch cloudSta1 {
                    case "SC":
                        cell2.imgViewForCloudDay1.image = UIImage(named:cloud1)
                    case "CL":
                        cell2.imgViewForCloudDay1.image = UIImage(named:cloud2)
                    case "FW":
                        cell2.imgViewForCloudDay1.image = UIImage(named:cloud1)
                    case "BK":
                       cell2.imgViewForCloudDay1.image = UIImage(named:cloud3)
                    case "OV":
                       cell2.imgViewForCloudDay1.image = UIImage(named:cloud3)
                    default:
                        cell2.imgViewForCloudDay1.image = UIImage(named:cloud2)
                    }
  
                    let cloudStatus2: String = self.Response_Aeris_Forecast[0].periods![2].cloudsCoded!
                    let cloudSta2 = cloudStatus2
                    switch cloudSta2 {
                    case "SC":
                        cell2.imgViewForCloudDay2.image = UIImage(named:cloud1)
                    case "CL":
                        cell2.imgViewForCloudDay2.image = UIImage(named:cloud2)
                    case "FW":
                        cell2.imgViewForCloudDay2.image = UIImage(named:cloud1)
                    case "BK":
                        cell2.imgViewForCloudDay2.image = UIImage(named:cloud3)
                    case "OV":
                        cell2.imgViewForCloudDay2.image = UIImage(named:cloud3)
                    default:
                        cell2.imgViewForCloudDay2.image = UIImage(named:cloud2)
                    }
                    
                    let cloudStatus3: String = self.Response_Aeris_Forecast[0].periods![3].cloudsCoded!
                    let cloudSta3 = cloudStatus3
                    switch cloudSta3 {
                    case "SC":
                        cell2.imgViewForCloudDay3.image = UIImage(named:cloud1)
                    case "CL":
                        cell2.imgViewForCloudDay3.image = UIImage(named:cloud2)
                    case "FW":
                        cell2.imgViewForCloudDay3.image = UIImage(named:cloud1)
                    case "BK":
                        cell2.imgViewForCloudDay3.image = UIImage(named:cloud3)
                    case "OV":
                        cell2.imgViewForCloudDay3.image = UIImage(named:cloud3)
                    default:
                        cell2.imgViewForCloudDay3.image = UIImage(named:cloud2)
                    }
                    
                    let cloudStatus4: String = self.Response_Aeris_Forecast[0].periods![4].cloudsCoded!
                    let cloudSta4 = cloudStatus4
                    switch cloudSta4 {
                    case "SC":
                        cell2.imgViewForCloudDay4.image = UIImage(named:cloud1)
                    case "CL":
                        cell2.imgViewForCloudDay4.image = UIImage(named:cloud2)
                    case "FW":
                        cell2.imgViewForCloudDay4.image = UIImage(named:cloud1)
                    case "BK":
                        cell2.imgViewForCloudDay4.image = UIImage(named:cloud3)
                    case "OV":
                        cell2.imgViewForCloudDay4.image = UIImage(named:cloud3)
                    default:
                        cell2.imgViewForCloudDay4.image = UIImage(named:cloud2)
                    }
                    
                    let cloudStatus5: String = self.Response_Aeris_Forecast[0].periods![5].cloudsCoded!
                 
                    let cloudSta5 = cloudStatus5
                    switch cloudSta5 {
                    case "SC":
                        cell2.imgViewForCloudDay5.image = UIImage(named:cloud1)
                    case "CL":
                        cell2.imgViewForCloudDay5.image = UIImage(named:cloud2)
                    case "FW":
                        cell2.imgViewForCloudDay5.image = UIImage(named:cloud1)
                    case "BK":
                        cell2.imgViewForCloudDay5.image = UIImage(named:cloud3)
                    case "OV":
                        cell2.imgViewForCloudDay5.image = UIImage(named:cloud3)
                    default:
                        cell2.imgViewForCloudDay5.image = UIImage(named:
                            cloud2)
                    }
                    
                    let cloudStatus6: String = self.Response_Aeris_Forecast[0].periods![6].cloudsCoded!
                    let cloudSta6 = cloudStatus6
                    switch cloudSta6 {
                    case "SC":
                        cell2.imgViewForCloudDay6.image = UIImage(named:cloud1)
                    case "CL":
                        cell2.imgViewForCloudDay6.image = UIImage(named:cloud2)
                    case "FW":
                        cell2.imgViewForCloudDay6.image = UIImage(named:cloud1)
                    case "BK":
                        cell2.imgViewForCloudDay6.image = UIImage(named:cloud3)
                    case "OV":
                        cell2.imgViewForCloudDay6.image = UIImage(named:cloud3)
                    default:
                        cell2.imgViewForCloudDay6.image = UIImage(named:cloud2)
                    }
                }
            }
            return cell2
        }else if indexPath.row == 2 {
            let cell3 : HumidityCell  = tableView.dequeueReusableCell(withIdentifier: "HumidityCell", for: indexPath) as! HumidityCell
            if self.Response_Aeris_Current.count != 0{
                let x : Int = (self.Response_Aeris_Current[0].periods![0].feelslikeC)!
                   cell3.lblForFeelsLike.text  = String(x)
                let Y : Int = (self.Response_Aeris_Current[0].periods![0].humidity)!
                cell3.lblForHumidity.text = String(Y)
                let Z : Int = (self.Response_Aeris_Current[0].periods![0].uvi)!
                cell3.lblForUVindex.text = String(Z)
            }
            return cell3
        }else if indexPath.row == 3{
            let cell4 : WindCell  = tableView.dequeueReusableCell(withIdentifier: "WindCell", for: indexPath) as! WindCell
            cell4.imgViewForGif.image = UIImage.gif(name: "wind2")
            if self.Response_Aeris_Current.count != 0{
                cell4.lblForWindDirection.text = self.Response_Aeris_Current[0].periods![0].windDir!
                
                if  UserDefaults.standard.bool(forKey: "KmPerHour") != false{
                    let windSpeedKPH : Int = (self.Response_Aeris_Current[0].periods![0].windSpeedKPH)!
                    cell4.lblForWindSpeed.text = String(windSpeedKPH) + " KPH"
                }else if UserDefaults.standard.bool(forKey: "MiliPerHour") != false{
                    let windSpeedMPH : Int = (self.Response_Aeris_Current[0].periods![0].windSpeedMPH)!
                    cell4.lblForWindSpeed.text = String(windSpeedMPH) + " MPH"
                }else{
                    let windSpeedKPH : Int = (self.Response_Aeris_Current[0].periods![0].windSpeedKPH)!
                    cell4.lblForWindSpeed.text = String(windSpeedKPH) + " KPH"
                }
            }
            cell4.btnForMphOrKph.tag = indexPath.row
            cell4.btnForMphOrKph.addTarget(self, action: #selector(WeatherVC.ActionOnEdit(sender:)), for: .touchUpInside)
            return cell4
        }else {
            let cell5 : DayUpdateCell  = tableView.dequeueReusableCell(withIdentifier: "DayUpdateCell", for: indexPath) as! DayUpdateCell
            
            if self.Response_PhaseMoon.count != 0{
                let currentLat : Double = Double((self.Response_PhaseMoon[0].loc?.lat)!)
                let currentLong : Double = Double((self.Response_PhaseMoon[0].loc?.long)!)
                getTimeZoneFromLatLong(setLat: currentLat, setLOng: currentLong, handler: { str in
                  currentTimeZone = str
                    var getCurrentTimeForOtherCountry: String = ""
                    getCurrentTimeForOtherCountry = getCurrentTimeResult()
                    let isoRise: String = (self.Response_PhaseMoon[0].sun?.riseISO!)!
                    var pointsArr = isoRise.components(separatedBy: "T")
                    let r1 = pointsArr[1]
                    let r2 = r1.components(separatedBy: ":")
                    cell5.lblForSunRise.text = r2[0] + ":" + r2[1] + " AM"
                    let riseTime: String = cell5.lblForSunRise.text!
                    
                    let isoSet: String = (self.Response_PhaseMoon[0].sun?.setISO!)!
                    var setArr = isoSet.components(separatedBy: "T")
                    let s1 = setArr[1]
                    let s2 = s1.components(separatedBy: ":")
                    cell5.lblForSunSet.text = String(Int(s2[0])! - 12) + ":" + s2[1] + " PM"
                    let setTime: String = cell5.lblForSunSet.text!
                    
                    cell5.viewForDayRing.shapeLayer.removeFromSuperlayer()
                    cell5.viewForDayRing.getRisingTime = riseTime
                    cell5.viewForDayRing.getSettingTime = setTime
                    cell5.viewForDayRing.getCurrentTime = getCurrentTimeForOtherCountry
                    cell5.viewForDayRing.makeArcPathOfSun()
                })
                
                let moonPhase = self.Response_PhaseMoon[0].moon?.phase?.name!
                if moonPhase == "waxing crescent"{
                    cell5.lblForFirstQuarter.text = "waxing crescent"
                    cell5.imgViewForMoonPhase.image = UIImage(named: moonA)
                }else if moonPhase == "waxing gibbous"{
                    cell5.lblForFirstQuarter.text = "waxing gibbous"
                    cell5.imgViewForMoonPhase.image = UIImage(named: moonB)
                }else if moonPhase == "waning gibbous"{
                    cell5.lblForFirstQuarter.text = "waning gibbous"
                    cell5.imgViewForMoonPhase.image = UIImage(named: moonC)
                }else if moonPhase == "waning crescent"{
                    cell5.lblForFirstQuarter.text = "waning crescent"
                    cell5.imgViewForMoonPhase.image = UIImage(named: moonD)
                }else if moonPhase == "first quarter"{
                    cell5.lblForFirstQuarter.text = "first quarter"
                    cell5.imgViewForMoonPhase.image = UIImage(named: moonE)
                }else if moonPhase == "new moon"{
                    cell5.lblForFirstQuarter.text = "new moon"
                    cell5.imgViewForMoonPhase.image = UIImage(named: moonF)
                }else if moonPhase == "last quarter"{
                    cell5.lblForFirstQuarter.text = "last quarter"
                    cell5.imgViewForMoonPhase.image = UIImage(named: moonA)
                }else if moonPhase == "full moon"{
                    cell5.lblForFirstQuarter.text = "full moon"
                    cell5.imgViewForMoonPhase.image = UIImage(named: moonD)
                }
            }
            return cell5
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 120
        }else  if indexPath.row == 1{
            return 140
        }else  if indexPath.row == 2{
            return 150
        }else  if indexPath.row == 3{
            return 150
        }else  if indexPath.row == 4{
            return 200
        }else {
            return 120
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        if indexPath.row+1 == 5 {
           print("came to last row")
        }
    }
    
    func getCurrentTimeFromLatLong(sendTimeZone: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" //HH:mm:ssZ
        //formatter.dateFormat = "HH:mm a" //HH:mm:ssZ
        formatter.timeZone = TimeZone(abbreviation: sendTimeZone)
        let dn = Date()
        //let dn = Date().addingTimeInterval(3600)
        let dString = formatter.string(from: dn)
        print(dString,dn)
       return dString
    }
}
