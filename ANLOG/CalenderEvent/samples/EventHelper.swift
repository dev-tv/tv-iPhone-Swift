
import Foundation
import EventKit
class EventHelper
{
    let appleEventStore = EKEventStore()
    var MonthEvents: [EKEvent] = []
    var eventsDate:[Date] = []
    func getEventAccessAuthorised()-> Bool{
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        switch (status)
        {
        case EKAuthorizationStatus.notDetermined:
            return false
        case EKAuthorizationStatus.authorized:
            return true
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            return false
        }
    }
    
    func requestAccessToCalendar(){
        appleEventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                DispatchQueue.main.async {
                    print("User has access to calendar")
                }
            } else {
                DispatchQueue.main.async{
                    print("User has to change settings...goto settings to view access")
                }
            }
        })
    }
    
    
     //MARK:- Add Event Data.....
    func addEventOnIphone(title:String,startDate:Date,endDate:Date,handler:@escaping ((String,Bool)->Void))
    {
        if permissionCheck(){
            let event:EKEvent = EKEvent(eventStore: appleEventStore)
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            event.notes = "Analog clock app"
            if let alrm:EKAlarm = self.GetAlarm(date: startDate) {
                event.alarms = [alrm]
            }
            event.calendar = appleEventStore.defaultCalendarForNewEvents
            do {
                try appleEventStore.save(event, span: .thisEvent)
                print("events added with dates:")
                handler(event.eventIdentifier,true)
            } catch let e as NSError {
                print(e.description)
                 handler(e.description,false)
                return
            }
            print("Saved Event")
        }
    }
    
    func GetAlarm(date:Date)-> EKAlarm? {
        
        if let getAlertStr = UserDefaults.standard.string(forKey: "savedAlertCase") {
            let alrm : EKAlarm = EKAlarm(absoluteDate: date)
            var aInterval: TimeInterval = 0
            switch getAlertStr {
            case "":
                return nil
            case "0":
                aInterval = 0
                break
            case "1":
                aInterval = -5 * 60
                break
            case "2":
                aInterval = -15 * 60
                break
            case "3":
                aInterval = -30 * 60
                break
            case "4":
                aInterval = -1 * 60 * 60
                break
            case "5":
                aInterval = -2 * 60 * 60
                break
            case "6":
                aInterval = -24 * 60 * 60
                break
            case "7":
                aInterval = -48 * 60 * 60
                break
            default:
                aInterval = 0
                break
            }
            alrm.relativeOffset = aInterval
            return alrm
        }
        return nil
    }
   
    //MARK:- Update Event Data...
    func updateEventOnIphone(eventIdentifier: String, title:String,startDate:Date,endDate:Date,handler:@escaping ((String,Bool)->Void))
    {
        if permissionCheck(){
            let event:EKEvent = appleEventStore.event(withIdentifier: eventIdentifier)!
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            event.notes = "Analog clock app"
            event.calendar = appleEventStore.defaultCalendarForNewEvents
            if let alrm:EKAlarm = self.GetAlarm(date: startDate) {
                event.alarms = [alrm]
            }
            do {
                try appleEventStore.save(event, span: .thisEvent)
                print("events added with dates:")
                handler(event.eventIdentifier, true)
            } catch let e as NSError {
                print(e.description)
                handler(e.description, false)
                return
            }
            print("Saved Event")
        }
    }
   
    func permissionCheck()->Bool{
        if getEventAccessAuthorised(){
            return true
        }else {
            requestAccessToCalendar()
        }
        return false
    }
    
    func readEvents(date:Date, handler:@escaping (([EKEvent],[Date])->Void)) {
        if permissionCheck(){
            
            let startDate = date.startOfMonth()
            let EndDate = date.endOfMonth()
            let predicate = appleEventStore.predicateForEvents(withStart:startDate, end: EndDate, calendars: [])
            let events = appleEventStore.events(matching: predicate)
            MonthEvents.removeAll()
            for event in events {          
                MonthEvents.append(event)
                eventsDate.append(event.startDate)
            }
            handler(MonthEvents, eventsDate)
        }
    }
    
    
    func removeEvent(eventIdentifier: String){
        if permissionCheck(){
            if let event = appleEventStore.event(withIdentifier: eventIdentifier) {
                do {
                    try appleEventStore.remove(event, span: .thisEvent)
                    print(eventIdentifier, "<<< removed event ")
                }catch
                {
                    print(eventIdentifier, "<<< not removed error accured ")
                }
            }
        }
    }
}



