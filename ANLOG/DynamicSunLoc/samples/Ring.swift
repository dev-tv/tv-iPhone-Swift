

import Foundation
import UIKit

class Ring:UIView
{
    var minut : Int = 620
    var getAngle :Float = 0.0
    let shapeLayer = CAShapeLayer()
    fileprivate var linedash : [CGFloat] = [3,5]
    var convertedIntTime: Int? = nil
    var currentPoint: CGPoint?
    var getRisingTime:String = "06:00 AM"
    var getSettingTime: String = "06:00 PM"
    var getCurrentTime: String = "12:00 PM"
    
   
    override func draw(_ rect: CGRect)
    {
       //makeArcPathOfSun()
       
    }
    
    func makeArcPathOfSun(){
        let getupdateTime = convertTwelveToTwentyFourHourFormat(putTime: self.getCurrentTime)
        convertedIntTime = Int(getupdateTime)
        let getRiseT = convertTwelveToTwentyFourHourFormat(putTime: getRisingTime)
        let getTime: String = calculateTimeDifference(start: Int(getRiseT)!, end: convertedIntTime!)
        let getHourMIn = getHourMinTimeOnly(sendTime: getTime)
        let getHour  = getHourMIn.hourTime
        let getMin  = getHourMIn.minuteTime
        let totalMin = convertTimeIntoMinute(hour: getHour, minute: getMin)
        convertMinIntAngle(minute: totalMin)
        drawRingFittingInsideView()
    }
    
    internal func drawRingFittingInsideView()->()
    {
        if let layer = shapeLayer.sublayers{
            for i in layer  {
                i.removeFromSuperlayer()
            }
        }
         shapeLayer.removeFromSuperlayer()
        let desiredLineWidth:CGFloat = 2
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: self.frame.size.width/2, y: self.frame.size.height - 1/2),
            radius: self.frame.size.height/2 + 30,
            startAngle: CGFloat(180.0).toRadians(),
            endAngle: CGFloat(0.0).toRadians(),
            clockwise: true
        )
        shapeLayer.backgroundColor = UIColor.clear.cgColor
        linedash = [3,5]
        shapeLayer.lineDashPattern = linedash as [NSNumber]?
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = textColorLbl.textColor.cgColor
        shapeLayer.lineWidth = desiredLineWidth
        layer.addSublayer(shapeLayer)
        let point: CGPoint = pointOnCircle(radius: Float(self.frame.size.height/2 + 30), center: CGPoint(x: self.frame.size.width/2 - 10, y: self.frame.size.height - 10), angle: Float(CGFloat(self.getAngle).toRadians()))
        currentPoint = point
        let img : UIImageView = UIImageView()
        img.image = UIImage(named: cloud2)
        img.frame = CGRect(x: point.x , y: point.y, width: 20, height: 20)
        shapeLayer.addSublayer(img.layer)
    }
    
    func animateSun(){
        let path = UIBezierPath()
        let img : UIImageView = UIImageView()
        img.image = UIImage(named: cloud2)
        img.frame = CGRect(x: (currentPoint?.x)! , y: (currentPoint?.y)!, width: 20, height: 20)
        shapeLayer.addSublayer(img.layer)
        path.move(to: CGPoint(x: 5, y: 149))
        path.addQuadCurve(to: CGPoint(x: 0, y: (currentPoint?.y)!), controlPoint: CGPoint(x:(currentPoint?.x)!/2, y: 0))
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path.cgPath
        animation.repeatCount = 0
        animation.duration = 2.0
        img.layer.add(animation, forKey: "animate along path")
        img.center = CGPoint(x: 0, y: (currentPoint?.y)!)
    }
    
    //MARK:- conversion of minute into angle ...
    func convertMinIntAngle(minute: Int){
        let totalMin = getTotalMinForTotalAngle(riseTime: getRisingTime, SetTime: getSettingTime)
        let partialAngle: Double = Double (180.0 / Double(totalMin))
        let makeAngle: Double = Double(partialAngle * Double(minute))
        if makeAngle >= 0 && makeAngle <= 180{
          getAngle = Float(180 + makeAngle)
        }else{
            getAngle = 0
        }
    }
    
    func getTotalMinForTotalAngle(riseTime:String,SetTime: String) -> Int{
        let Rtime = convertTwelveToTwentyFourHourFormat(putTime: getRisingTime)
        let Stime = convertTwelveToTwentyFourHourFormat(putTime: getSettingTime)
        let getRtime = Int(Rtime)
        let getStime = Int(Stime)
        let totalTimeDiff = calculateTimeDifference(start: getRtime!, end: getStime!)
        let getHourMIn = getHourMinTimeOnly(sendTime: totalTimeDiff)
        let getHour  = getHourMIn.hourTime
        let getMin  = getHourMIn.minuteTime
        let totalMin = convertTimeIntoMinute(hour: getHour, minute: getMin)
        return totalMin
    }
    
    func pointOnCircle(radius:Float, center:CGPoint,angle: Float) -> CGPoint {
        let theta = Float(angle)
        let x = radius * cos(theta)
        let y = radius * sin(theta)
        return CGPoint(x: CGFloat(x)+center.x,y: CGFloat(y)+center.y)
    }
    
    //MARK: @IBInspectable
    @IBInspectable var MeterColor: UIColor = UIColor.clear {
        didSet {
            shapeLayer.strokeColor = MeterColor.cgColor
        }
    }
    
    //MARK:- conversion for 12 hour format into 24 hour format..
    func convertTwelveToTwentyFourHourFormat(putTime: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.locale = NSLocale(localeIdentifier:"en_US_POSIX") as Locale!
        let date: Date? = dateFormatter.date(from: putTime)
        dateFormatter.dateFormat = "HH:mm"
        var getStrWithoutColon : String = ""
        if let aDate = date {
            let convertedString = dateFormatter.string(from: aDate)
            getStrWithoutColon = convertedString.replacingOccurrences(of: ":", with: "")
        }
        return getStrWithoutColon
    }

    //MARK:- get the time difference of two time...
    func calculateTimeDifference(start: Int, end: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmm"
        var startString = "\(start)"
        if startString.characters.count < 4 {
            for _ in 0..<(4 - startString.characters.count) {
                startString = "0" + startString
            }
        }
        var endString = "\(end)"
        if endString.characters.count < 4 {
            for _ in 0..<(4 - endString.characters.count) {
                endString = "0" + endString
            }
        }
        let startDate = formatter.date(from: startString)!
        let endDate = formatter.date(from: endString)!
        let difference = endDate.timeIntervalSince(startDate)
        return "\(Int(difference) / 3600): \(Int(difference) % 3600 / 60)"
    }
    
    //MARK:- convert time into minute....
    func convertTimeIntoMinute(hour: Int, minute: Int) -> Int{
        let totalMinute = (hour * 60) + minute
        return totalMinute
    }
    
    func getHourMinTimeOnly(sendTime: String)-> (hourTime: Int,minuteTime: Int){
        var parts : [String] = []
        parts = (sendTime.components(separatedBy: ":"))
        let hourValue = parts[0]
        let minValue = parts[1]
        let hourRow = (hourValue as NSString).integerValue
        let minRow = (minValue as NSString).integerValue
        return (hourRow,minRow )
    }
}

extension CGFloat {
    func toRadians() -> CGFloat {
        return self * CGFloat(M_PI) / 180.0
    }
}
