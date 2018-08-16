

import Foundation
import UIKit
import EventKit
import CoreData
protocol CalendarDateSelection {
    func selectedDate(date:Date,events: [EKEvent])
}

class AKCalender: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MonthViewDelegate {
    
    var numOfDaysInMonth = [31,28,31,30,31,30,31,31,30,31,30,31]
    var currentMonthIndex: Int = 0
    var currentYear: Int = 0
    var presentMonthIndex = 0
    var presentYear = 0
    var todaysDate = 0
    var todayYear = 0
    var firstWeekDayOfMonth = 0   //(Sunday-Saturday 1-7)
    var currentDate: Date = Date()
    var AllCalendersEvent: [EKEvent] = []
    var AllEventsDate: [Int] = []
    var selectionDelegate : CalendarDateSelection?
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        initializeView()
        getTodayYear()
    }
    func reloadCalender(){
        initializeView()
    }
    func initializeView() {
        self.AllCalendersEvent.removeAll()
        self.AllEventsDate.removeAll()
        currentMonthIndex = Calendar.current.component(.month, from: currentDate)
        currentYear = Calendar.current.component(.year, from: currentDate)
        todaysDate = Calendar.current.component(.day, from: currentDate)
        firstWeekDayOfMonth=getFirstWeekDay()
        if currentMonthIndex == 2 && currentYear % 4 == 0 {
            numOfDaysInMonth[currentMonthIndex-1] = 29
        }
        
        //end
        presentMonthIndex=currentMonthIndex
        presentYear=currentYear
        setupViews()
        EventsFromIphone()
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(dateCVCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.reloadData()
    }
    
    func getTodayYear(){
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        todayYear = year
        print(todayYear)
    }
    
    func EventsFromIphone(){
        self.AllCalendersEvent.removeAll()
        self.AllEventsDate.removeAll()
        getDataFromCoreData()
    }
    var eventList: [UserEvent] = []
    func getDataFromCoreData(){
        let appDelegate = (UIApplication.shared.delegate)as!AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        // Create the request
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserEvent")
        // Build the predicate
        
        let monthEnd:String = "\(currentYear)-\(currentMonthIndex)-\(numOfDaysInMonth[currentMonthIndex-1])"
        let monthStart:String = "\(currentYear)-\(currentMonthIndex)-01"
        
        let EndDate:Date = monthEnd.date!
        let StartDate:Date = monthStart.date!
        let predicate : NSPredicate = NSPredicate(format:"eventStartDate >= %@ && eventStartDate <= %@", StartDate as NSDate,EndDate  as NSDate)
        fetchRequest.predicate = predicate;
        let sortDesc = NSSortDescriptor(key: "eventStartDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDesc];
        
        do{
            let result = try context.fetch(fetchRequest)
            eventList =  result as![UserEvent]
            if eventList.count == 0{
                print("no action")
            }else{
                for event in eventList {
                    //print(eventDate.description)
                    let day = Calendar.current.component(.day, from: event.eventStartDate!)
                    if !self.AllEventsDate.contains(day) {
                        self.AllEventsDate.append(day)
                    }
                }
            }
            self.myCollectionView.reloadData()
        }
        catch
        {
            print("error")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numOfDaysInMonth[currentMonthIndex-1] + firstWeekDayOfMonth - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! dateCVCell
        cell.setupViews()
        cell.backgroundColor=UIColor.clear
        if indexPath.item <= firstWeekDayOfMonth - 2 {
            cell.isHidden=true
        } else {
            let calcDate = indexPath.row-firstWeekDayOfMonth+2
            cell.isHidden=false
            cell.lbl.text="\(calcDate)"
            if AllEventsDate.contains(calcDate) {
                cell.bgView.backgroundColor = hexStringToUIColor(hex: "#D6C4DB")
            }else {
                cell.bgView.backgroundColor = UIColor.clear
            }
            if calcDate == todaysDate && currentYear == presentYear && currentMonthIndex == presentMonthIndex  {
                if currentYear != todayYear{
                    cell.lbl.textColor = UIColor.red
                    let color1 = hexStringToUIColor(hex: "#235198")
                    cell.bgView.layer.borderColor = color1.cgColor
                    cell.bgView.layer.borderWidth = 0
                    cell.bgView.layer.masksToBounds = true
                    cell.bgView.layer.cornerRadius = (cell.frame.height / 2) - 1
                }else{
                    cell.lbl.textColor = UIColor.red
                    let color1 = hexStringToUIColor(hex: "#235198")
                    cell.bgView.layer.borderColor = color1.cgColor
                    cell.bgView.layer.borderWidth = 2
                    cell.bgView.layer.masksToBounds = true
                    cell.bgView.layer.cornerRadius = (cell.frame.height / 2) - 1
                }
            }else {
                cell.bgView.layer.borderColor = UIColor.clear.cgColor
                cell.bgView.layer.borderWidth = 2
                cell.bgView.layer.cornerRadius = 5
                cell.bgView.layer.masksToBounds = true
            }
            cell.isUserInteractionEnabled=true
            cell.lbl.textColor = UIColor.black
            cell.lbl.textAlignment = .center
            cell.lblline.isHidden = true
        }
        cell.width = collectionView.frame.width / 7
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let calcDate = indexPath.row-firstWeekDayOfMonth+2
        var strdate = ""
        if currentMonthIndex<10 {
            strdate = "\(currentYear)-0\(currentMonthIndex)-"
        }else {
            strdate = "\(currentYear)-\(currentMonthIndex)-"
        }
        if calcDate < 10 {
            strdate += "0\(calcDate)"
        }else {
            strdate += "\(calcDate)"
        }
        if let date :Date = strdate.newdate {
            let eve :[EKEvent] = AllCalendersEvent.filter({$0.startDate == date.toLocalTime()})
            print(eve)
            self.selectionDelegate?.selectedDate(date:date.toLocalTime(),events: eve)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/7
        //let height: CGFloat = 30
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func getFirstWeekDay() -> Int {
        let day = ("\(currentYear)-\(currentMonthIndex)-01".date?.firstDayOfTheMonth.weekday)!
        //return day == 7 ? 1 : day
        return day
    }
    
    func didChangeMonth(monthIndex: Int, year: Int) {
        currentMonthIndex=monthIndex+1
        currentYear = year
        
        //for leap year, make february month of 29 days
        if monthIndex == 1 {
            if currentYear % 4 == 0 {
                numOfDaysInMonth[monthIndex] = 29
            } else {
                numOfDaysInMonth[monthIndex] = 28
            }
        }
        
        //end
        firstWeekDayOfMonth=getFirstWeekDay()
        myCollectionView.reloadData()
        
        let strTime:String = "\(currentYear)-\(currentMonthIndex)-01"
        currentDate = strTime.date!
        
        EventsFromIphone()
        myCollectionView.reloadData()
        
    }
    
    func setupViews() {
        addSubview(monthView)
        monthView.currentYear = currentYear
        monthView.currentMonthIndex = currentMonthIndex - 1
        monthView.setupViews()
        //monthView.topAnchor.constraint(equalTo: topAnchor).isActive=true
        monthView.topAnchor.constraint(equalTo: topAnchor, constant: 10.0).isActive = true
        monthView.leftAnchor.constraint(equalTo: leftAnchor).isActive=true
        monthView.rightAnchor.constraint(equalTo: rightAnchor).isActive=true
        monthView.heightAnchor.constraint(equalToConstant: 45).isActive=true
        monthView.delegate=self
        
        addSubview(weekdaysView)
        weekdaysView.topAnchor.constraint(equalTo: monthView.bottomAnchor, constant:5.0).isActive=true
        weekdaysView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10.0).isActive=true
        weekdaysView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10.0).isActive=true
        weekdaysView.heightAnchor.constraint(equalToConstant: 25).isActive=true
        
        addSubview(myCollectionView)
        myCollectionView.topAnchor.constraint(equalTo: weekdaysView.bottomAnchor, constant: 0).isActive=true
        myCollectionView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10.0).isActive=true
        myCollectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10.0).isActive=true
        myCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive=true
    }
    
    let monthView: MonthView = {
        let v=MonthView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    let weekdaysView: WeekdaysView = {
        let v=WeekdaysView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    let myCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let myCollectionView=UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        myCollectionView.showsHorizontalScrollIndicator = false
        myCollectionView.translatesAutoresizingMaskIntoConstraints=false
        myCollectionView.backgroundColor=UIColor.clear
        myCollectionView.allowsMultipleSelection=false
        return myCollectionView
    }()
    //changeMonthAction
    func NextMonth(){
        monthView.changeMonthAction(sender: 1)
    }
    func PreviousMonth(){
        monthView.changeMonthAction(sender:0)
    }
}

class dateCVCell: UICollectionViewCell {
    var width :CGFloat = 0.0
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor=UIColor.clear
        bgView.layer.cornerRadius=5
        bgView.layer.masksToBounds=true
        setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bgView.backgroundColor = UIColor.clear
        backgroundColor=UIColor.clear
        layer.cornerRadius=5
        layer.masksToBounds=true
        width = 0.0
    }
    func setupViews() {
        
        addSubview(bgView)
        bgView.topAnchor.constraint(equalTo: topAnchor,constant: 1).isActive=true
        bgView.leftAnchor.constraint(equalTo: leftAnchor,constant: 1).isActive=true
        bgView.rightAnchor.constraint(equalTo: rightAnchor,constant: -1).isActive=true
        bgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive=true
        
        
        
        addSubview(lbl)
        lbl.topAnchor.constraint(equalTo: topAnchor).isActive=true
        lbl.leftAnchor.constraint(equalTo: leftAnchor).isActive=true
        lbl.rightAnchor.constraint(equalTo: rightAnchor).isActive=true
        lbl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive=true
        lbl.widthAnchor.constraint(equalToConstant: width)
        addSubview(lblline)
        lblline.topAnchor.constraint(equalTo: lbl.bottomAnchor).isActive=true
        lblline.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive=true
        lblline.rightAnchor.constraint(equalTo: rightAnchor, constant:-5).isActive=true
        lblline.bottomAnchor.constraint(equalTo: bottomAnchor).isActive=true
    }
    
    let lbl: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.textAlignment = .center
        //label.font=UIFont.systemFont(ofSize: 5)
        if UIDevice.current.modelName == "iPhone 5" {
            label.font=UIFont.systemFont(ofSize: 10)
        }else{
            label.font=UIFont.systemFont(ofSize: 15)
        }
        label.textColor  = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints=false
        return label
    }()
    let lblline: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.textColor  = UIColor.red
        label.backgroundColor = UIColor.red
        label.translatesAutoresizingMaskIntoConstraints=false
        return label
    }()
    
    let bgView: UIView = {
        let bg = UIView()
        bg.backgroundColor = UIColor.red
        bg.translatesAutoresizingMaskIntoConstraints=false
        return bg
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//get first day of the month
extension Date {
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    var firstDayOfTheMonth: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
    }
    var dateString:String {
        
        return  Date.dateFormatter.string(from: self)
    }
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
}

//get date from string
extension String {
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static var newdateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var newdate: Date? {
        return String.newdateFormatter.date(from: self)
    }
    
    var date: Date? {
        return String.dateFormatter.date(from: self)
    }
    var dateAMPM: Date? {
        return String.AmPmDateFormatter.date(from: self)
    }
    static var AmPmDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm a"
        return formatter
    }()
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.characters.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

