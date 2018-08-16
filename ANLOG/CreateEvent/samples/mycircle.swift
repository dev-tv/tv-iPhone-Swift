//
//  mycircle.swift
//  clock
//
//  Created by Dev3 on 5/22/18.
//  Copyright © 2018 Dev. All rights reserved.
//

import Foundation
import UIKit

protocol getTimeDelegate {
    func getStartTime(start: String,end: String,colorIndex: Int,statusForAMPM: String,getCurrentDayAmPm: String)
    func showCreateEventClass()
}

@IBDesignable class Mycircle: UIView {
      var eventList: [UserEvent] = []
   // #MARK:- Creating outlet of ui component
    var delegate: getTimeDelegate?
    var viewCenter: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var startPoint : CGPoint = CGPoint(x: 0.0, y: 0.0)
    var endPoint : CGPoint = CGPoint(x: 0.0, y: 0.0)
    
    var startAngle: Float = 0.0
    var endAngle: Float = 0.0
    
   // var showColor: UIColor = UIColor.black
    let shapeLayer: CAShapeLayer = CAShapeLayer()
    let startTextLayer : CATextLayer = CATextLayer()
    let endTextLayer : CATextLayer = CATextLayer()
    var currentTime : String = ""
    var getCurrentTimeStatus : String = ""
    var setAmPm : String = ""
    var getColorIndex : Int = Int()
    var point : CGPoint = CGPoint()
    var startAtTime : String = ""
    var endAtTime : String = ""
    
    //When creating the view in code
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // #MARK:- Initialize the init coder
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // #MARK:- Initialize draw rect
    override func draw(_ rect: CGRect) {
        viewCenter = CGPoint(x: rect.width / 2, y: rect.height / 2)
    }
    
    func getHourTime(sendTime: String)-> (hourTime: Int,strForAMPM: String){
        var parts : [String] = []
        parts = (sendTime.components(separatedBy: ":"))
        let hourValue = parts[0]
        let minValue = parts[1]
        let hourRow = (hourValue as NSString).integerValue
        let minRow = (minValue as NSString).integerValue
        let fullNameArr = minValue.characters.split{$0 == " "}.map(String.init)
        var lblForAMPM: String = ""
        lblForAMPM = fullNameArr[1]
        return (hourRow,lblForAMPM)
    }
    
    //MARK:- get curent Time
    func currentTimestamp() -> String{
        currentTime = universalCurrentTime
        let getCurrent  = getHourTime(sendTime: currentTime)
        return getCurrent.strForAMPM
    }
    
    // #MARK:- Code write for custom layer drawing
    func customlayerDrawing(startAngle: Float, endAngle: Float,color : UIColor){
        let path = UIBezierPath()
        path.move(to: viewCenter)
        path.addArc(withCenter: viewCenter, radius: CGFloat((self.frame.width / 2) - 20), startAngle: CGFloat(11 * Double.pi / 6), endAngle: CGFloat(Double.pi / 4), clockwise: true)
        let customeLayer: CAShapeLayer = CAShapeLayer()
        customeLayer.path = path.cgPath
        customeLayer.fillColor = color.cgColor
        customeLayer.strokeColor = UIColor.clear.cgColor
        customeLayer.lineWidth = 0;
        self.layer.addSublayer(customeLayer)
    }
  
    // #MARK:- Code write for starting the dragging view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: self)
            startPoint = position
             getColorIndex = randomNumber()
            print(position)
        }
    }
    
    // #MARK:- Code write for move to the point of the dragging view
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: self)
            endPoint = position
            print(position)
            layerDrawing()
            newTimeCalculation()
        }
        
         getCurrentTimeStatus = currentTimestamp()
        //getCurrentTimeStatus = "AM"
         let getStartTime = calculateEndTimeFromAngle(angle: startAngle)
         let getEndTime = calculateEndTimeFromAngle(angle: endAngle)
         let diff = calculateTimeDiffInMinute(startTime: getStartTime, endTime: getEndTime)
        if diff >= 0{
            if getCurrentTimeStatus == "PM"{
                 setAmPm = "PM"
            }else{
                setAmPm = "AM"
            }
        }else{
            if getCurrentTimeStatus == "PM"{
                setAmPm = "AM"
            }else{
                setAmPm = "PM"
            }
        }
        endTextLayer.frame = CGRect(x: endPoint.x, y: endPoint.y - 60, width: 80, height: 21)
        if startAngle >= 90 && startAngle <= 270{
           startTextLayer.frame = CGRect(x: startPoint.x - 70, y: startPoint.y - 40, width: 80, height: 21)
        }
        if startAngle > 270 && startAngle <= 360 || startAngle >= 0 && startAngle < 90 {
            startTextLayer.frame = CGRect(x: startPoint.x + 10, y: startPoint.y - 40, width: 80, height: 21)
        }
    }
    
    // #MARK:- Code write for move to the end point of the dragging view
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: self)
            endPoint = position
            print(position)
            layerDrawing()
        }
        var popUpDiff : Float = Float()
        if startAngle > endAngle{
          popUpDiff = startAngle - endAngle
        }else if endAngle > startAngle{
          popUpDiff = endAngle - startAngle
        }
        if popUpDiff > 10.0{
            delegate?.showCreateEventClass()
        }else{
            shapeLayer.removeFromSuperlayer()
        }
        endTextLayer.frame = CGRect(x: endPoint.x, y: endPoint.y - 60, width: 80, height: 21)
    }
    
    // #MARK:- Code write for layer drawinig of the dragging view
    func getRunningRadius() -> CGFloat {
        print("start Angle>>>>",startAngle,"end Angle>>>>",endAngle)
        var a = endAngle - startAngle
        a += (a>180) ? -360 : (a < -180) ? 360 : 0
        if a < 0 {
            a += 360
        }
        print("calculated diff>>>",a)
        let width :Float = Float(a / 72.0)
        //getWidth(sender: Int(Int(a) / 30))
        let rad:CGFloat = self.frame.width / 3
        let radius: CGFloat = (CGFloat(rad) + CGFloat(12 * width))
        return radius
    }
    func layerDrawing(){
        startAngle = Float(viewCenter.angle(to: startPoint))
        endAngle = Float(viewCenter.angle(to: endPoint))
        
        let radius : CGFloat = getRunningRadius()
        let path = UIBezierPath()
        path.move(to: viewCenter)
        path.addArc(withCenter: viewCenter, radius:radius , startAngle: startAngle.degreesToRadians, endAngle: endAngle.degreesToRadians, clockwise: true)
        shapeLayer.path = path.cgPath
        let  getColor = arrForColorCode[getColorIndex]
        shapeLayer.fillColor = getColor.cgColor.copy(alpha: 0.6)
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 0;
        self.layer.addSublayer(shapeLayer)
        self.shapeLayer.addSublayer(endTextLayer)
        self.shapeLayer.addSublayer(startTextLayer)
        endTextLayer.frame = CGRect(x: endPoint.x, y: endPoint.y - 60, width: 80, height: 21)
        endTextLayer.fontSize = 15
        startTextLayer.fontSize = 15
        endTextLayer.alignmentMode = kCAAlignmentLeft
        startTextLayer.alignmentMode = kCAAlignmentLeft
        endTextLayer.contentsScale = UIScreen.main.scale
        startTextLayer.contentsScale = UIScreen.main.scale
        startTextLayer.foregroundColor = textColorLbl.textColor.cgColor
        endTextLayer.foregroundColor = textColorLbl.textColor.cgColor
        let getEndTime = calculateEndTimeFromAngle(angle: endAngle)
        let getStartTime = calculateStartTimeFromAngle(angle: startAngle)
        endTextLayer.string = getEndTime + " " + setAmPm
        startTextLayer.string = getStartTime + " " + getCurrentTimeStatus
    }
    
    // #MARK:- Code write Calculating the time from angle
    func newTimeCalculation(){
         startAtTime  = calculateStartTimeFromAngle(angle: startAngle)
         endAtTime  = calculateEndTimeFromAngle(angle: endAngle)
        self.delegate?.getStartTime(start: startAtTime,end: endAtTime, colorIndex: getColorIndex,statusForAMPM: self.setAmPm,getCurrentDayAmPm: self.getCurrentTimeStatus)
    }
    
    // #MARK:- Mehod write for getting time from angle for start angle..
    func calculateStartTimeFromAngle(angle: Float) -> String{
        var time : String = ""
        var decimalValue: Float = 3.0 + (1.0 / 30.0) * (angle.truncatingRemainder(dividingBy: 360))
        if decimalValue < 0{
            decimalValue = decimalValue + 12.0
        }
        
        var hours : Int = Int(decimalValue)
        if getCurrentTimeStatus == "PM"{
            if hours == 0 || hours == 12{
                hours = 12
            }
        }else if getCurrentTimeStatus == "AM"{
            if hours == 0 || hours == 12{
                hours = 0
            }
        }
        
        if hours == 13{
            hours = 1
        }
        if hours == 14{
            hours = 2
        }
        
        if hours < 10 && hours >= 0{
            time = "0" + time + String(hours) + ":"
        }else if hours == 10 {
            time = time + String(hours) + ":"
        }else if hours > 10 {
            time = time + String(hours) + ":"
        }
        else{
            time = time + String(hours) + ":"
        }
        
        var minute : Int = Int(decimalValue * 60) % 60
        if minute < 10{
            minute = 0
            time = time + "0" + String(minute)
                    }else{
             if minute >= 10 && minute < 45{
             minute = 30
             time = time + String(minute)
             }
             if minute >= 45 && minute < 60{
                if hours == 12{
                    hours = 0
                }
             hours = hours + 1
             minute = 0
                if String(hours).count == 1{
                    time = "0" + String(hours) + ":" + String(minute) + "0"
                }else{
                    time = String(hours) + ":" + String(minute) + "0"
                }
             }
        }
        return time
    }
    
     // #MARK:- Mehod write for getting time from angle for end angle..
    func calculateEndTimeFromAngle(angle: Float) -> String{
        var time : String = ""
        var decimalValue: Float = 3.0 + (1.0 / 30.0) * (angle.truncatingRemainder(dividingBy: 360))
        if decimalValue < 0{
            decimalValue = decimalValue + 12.0
        }
        var hours : Int = Int(decimalValue)
        if hours == 0{
            hours = 12
        }else if hours == 13{
            hours = 1
        }else if hours == 14{
            hours = 2
        }
        
        if hours < 10 && hours > 0{
             time = "0" + time + String(hours) + ":"
        }else if hours == 10 {
             time = time + String(hours) + ":"
        }else if hours > 10 {
             time = time + String(hours) + ":"
        }
        else{
            time = time + String(hours) + ":"
        }
        
        var minute : Int = Int(decimalValue * 60) % 60
        if minute < 10{
            minute = 0
            time = time + "0" + String(minute)
        }else{
            if minute >= 10 && minute < 45{
               minute = 30
               time = time + String(minute)
            }
            if minute >= 45 && minute < 60{
                if hours == 12{
                    hours = 0
                }
                hours = hours + 1
                minute = 0
                if String(hours).count == 1{
                    time = "0" + String(hours) + ":" + String(minute) + "0"
                }else{
                    time = String(hours) + ":" + String(minute) + "0"
                }
            }
        }
        return time
    }
   
  
    func DayEventslayerDrawing(startAngel:Float, endAngle:Float, color: UIColor, randonRadii:CGFloat,layerWidth:CGFloat){
        let path = UIBezierPath()
        
        //CGFloat(randonRadii)
        path.addArc(withCenter: viewCenter, radius:randonRadii , startAngle: startAngel.degreesToRadians, endAngle: endAngle.degreesToRadians, clockwise: true)
        let newLayer : CAShapeLayer = CAShapeLayer()
        newLayer.path = path.cgPath
        newLayer.fillColor = UIColor.clear.cgColor
        newLayer.strokeColor = color.withAlphaComponent(0.6).cgColor
        newLayer.lineWidth = layerWidth
        self.layer.addSublayer(newLayer)
    }
    
    func shortArraywithDuration(){
        var sequencearray:[UserEvent] = []
        for j in 0...12 {
        for i in 0..<eventList.count {
            if  let st :String = eventList[i].eventStartTime {
                if let et :String = eventList[i].eventEndTime {
                    let getdiff :Int = self.getDiffrence(startTime: st, endTime: et)
                    var diff : Int = Int()
                    if getdiff < 0{
                         diff = getdiff + 24
                    }else{
                        diff = getdiff
                    }
                    if diff == j {
                        sequencearray.append(eventList[i])
                   }
                }
             }
         }
      }
       eventList = sequencearray.reversed()
    }
    
    func SetDayAngleFromTime(){
        self.layer.sublayers?.removeAll()
        shortArraywithDuration()
        var getStartAngle: Float = 0.0
        var getEndAngle: Float = 0.0
        var color : UIColor = UIColor.white
        let angleCount: Int = eventList.count
        let radius:CGFloat = self.frame.width / 3
        for i in 0..<angleCount {
        if  let st :String = eventList[i].eventStartTime {
          getStartAngle = Float(splitHourMinuteForStartTime(getTime: st))
                if let et :String = eventList[i].eventEndTime {
         getEndAngle = Float(splitHourMinuteForStartTime(getTime: et))
         let getColour : UIColor = arrForColorCode[Int(eventList[i].colorIndex)] as UIColor
                color = getColour.withAlphaComponent(0.6)
                let getDiff :Int = self.getDiffrence(startTime: st, endTime: et)
                var diff : Int = Int()
                if getDiff < 0{
                  diff = getDiff + 24
                }else{
                diff = getDiff
            }
            let randomWidth = self.getWidth(sender: diff)
            let R :CGFloat = radius + CGFloat((randomWidth / 2))
            DayEventslayerDrawing(startAngel: getStartAngle, endAngle: getEndAngle, color: color, randonRadii: R, layerWidth: CGFloat(randomWidth))
                }
            }
        }
    }
    
    func getDiffrence(startTime:String,endTime:String) -> Int{
        let getSTime  =  convertTwelveToTwentyFourHourFormat(putTime: startTime)
        let getETime = convertTwelveToTwentyFourHourFormat(putTime: endTime)
        let todayDate: String = getTodayDate()
        let tStartTime = todayDate + " " + getSTime
        let eEndTime = todayDate + " " + getETime
        let getStartDate:Date = convertStringToDate2(tStartTime, dateFormat: "yyyy-MM-dd HH:mm")!
        let getEndDate :Date = convertStringToDate2(eEndTime, dateFormat: "yyyy-MM-dd HH:mm")!
        let diff:Int = getEndDate.hours(from: getStartDate)
        return diff
    }
    
  
    //MARK:- conversion for 12 hour format into 24 hour format..
    func convertTwelveToTwentyFourHourFormat(putTime: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.locale = NSLocale(localeIdentifier:"en_US_POSIX") as Locale!
        let date: Date? = dateFormatter.date(from: putTime)
        dateFormatter.dateFormat = "HH:mm"
        var getStrWithColon : String = ""
        if let aDate = date {
            let convertedString = dateFormatter.string(from: aDate)
            getStrWithColon = convertedString
        }
        return getStrWithColon
    }
    
    
    func getTodayDate() -> String{
        let todaysDate:NSDate = NSDate()
        let dateFormatter2:DateFormatter = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd"
        let todayString:String = dateFormatter2.string(from: todaysDate as Date)
        return todayString
    }
    
    func convertStringToDate2(_ strDate: String, dateFormat: String) -> Date? {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.timeZone = TimeZone.autoupdatingCurrent
        let date = formatter.date(from: strDate)
        return date;
    }
    func getWidth(sender:Int) ->Int {
        if sender == 1  {
            return 20
        }else if sender  == 2  {
            return 25
        }else if sender  == 3  {
            return 30
        }else if sender  == 4  {
            return 35
        }else if sender  == 5  {
            return 40
        }else if sender  == 6 {
            return 45
        }else if sender  == 7  {
            return 48
        }else if sender  == 8  {
            return 50
        }else if sender  == 9  {
            return 52
        }else if sender  == 10{
            return 55
        }else if sender  == 11{
            return 58
        }else {
            return 20
        }
   
    }
    
    func splitHourMinuteForStartTime(getTime: String) -> Float{
        var parts : [String] = []
        parts = (getTime.components(separatedBy: ":"))
         let hourValue = parts[0]
        let minValue = parts[1]
        var hourRow: NSInteger?
        var minRow: NSInteger?
        hourRow = (hourValue as NSString).integerValue
        minRow = (minValue as NSString).integerValue
        let hourRowFloat = Float(hourValue)
        let minRowFloat = Float(minRow!)
        var getStartAng: Float = 0.0
        getStartAng = self.convertTimeIntoAngle(hour: hourRowFloat!, minute: minRowFloat)
        return getStartAng
    }
    
    func convertTimeIntoAngle(hour: Float, minute: Float) -> Float{
        let minToHour : Float = Float(minute / 60)
        let totalHour: Float = Float(hour) + Float(minToHour)
        let angle : Float = Float((360/12) * totalHour - 90)
        return angle
    }
    
    func randomNumber(range: ClosedRange<Int> = 137...167) -> Int {
        let min = range.lowerBound
        let max = range.upperBound
        return Int(arc4random_uniform(UInt32(1 + max - min))) + min
    }
    
    let MAX : UInt32 = 19
    let MIN : UInt32 = 0
    func randomNumber() -> Int
    {
        var random_number = Int(arc4random_uniform(MAX) + MIN)
        print ("random = ", random_number);
        return random_number
        
    }
    
    //MARK:- calculate time differne between two time
    func calculateTimeDiffInMinute(startTime: String,endTime: String) -> Int{
        var parts1 : [String] = []
        parts1 = (startTime.components(separatedBy: ":"))
        let hourValue1 = parts1[0]
        let minValue1 = parts1[1]
        var hourRow1: NSInteger?
        var minRow1: NSInteger?
        //hourRow1 = Int(hourValue1)
        let calcHour1 = Int(hourValue1)
        if calcHour1 == 12{
            hourRow1 = 0
        }else{
            hourRow1 = calcHour1
        }
        minRow1 = Int(minValue1)
        let startTotalMin : Int = hourRow1! * 60 + minRow1!
        
        var parts2 : [String] = []
        parts2 = (endTime.components(separatedBy: ":"))
        let hourValue2 = parts2[0]
        let minValue2 = parts2[1]
        var hourRow2: NSInteger?
        var minRow2: NSInteger?
        //hourRow2 = Int(hourValue2)
        let calcHour = Int(hourValue2)
        if calcHour == 12{
           hourRow2 = 0
        }else{
           hourRow2 = calcHour
        }
        minRow2 = Int(minValue2)
        let endTotalMin : Int = (hourRow2! * 60) + minRow2!
        let getTimeDiff: Int = endTotalMin - startTotalMin
        return getTimeDiff
    }
}

 // #MARK:- Mehod write for calculating angle from given points
extension CGPoint {
    func angle(to comparisonPoint: CGPoint) -> CGFloat {
        let originX = comparisonPoint.x - self.x
        let originY = comparisonPoint.y - self.y
        let bearingRadians = atan2f(Float(originY), Float(originX))
        var bearingDegrees = CGFloat(bearingRadians).degrees
        while bearingDegrees < 0 {
           bearingDegrees += 360
        }
        return bearingDegrees
    }
}

 // #MARK:- Mehod write for getting degrees
extension CGFloat {
    var degrees: CGFloat {
        return self * CGFloat(180.0 / Double.pi)
    }
}

// #MARK:- Mehod write for getting radians from angle
extension Float {
    var degreesToRadians : CGFloat {
        return CGFloat(self) * CGFloat(Double.pi) / 180.0
    }
}
