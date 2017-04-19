import UIKit
import CoreLocation

class Session: NSObject
{
    var title: String! = ""
    var isOnGoing: Bool!       // Session is in progress or not
    
    // Date & Duration
    let startDate: Date?
    var endDate: Date?
    var duration: Int! = 0
    
    // AP Internet & Bluetooth
    var internetAP: String = "ND"
    // var bleDevice: String = "ND"
    
    // Battery level
    var startBatteryLevel: String = "ND"
    var endBatteryLevel: String = "ND"
    
    var triggerdLocs = [GPSLocalisation]()  // Array of Localisation associated to Session
    
    
    init(titleSession: String, isOnGoing: Bool)
    {
        self.title = titleSession
        self.isOnGoing = isOnGoing
        self.startDate = dateFormatter.date(from: getCurrentTimestamp())    // Set Start Date
    }
    
    
    func setTitle(titleSession: String)
    {
        self.title = titleSession
    }
    
    
    func setBatteryLevel(onStart: Bool, level: String)
    {
        self.setInternetAP()    /* TESTING PURPOSES - REMOVE ASAP */

        if onStart { self.startBatteryLevel = level }
        else { self.endBatteryLevel = level }
    }
    
    
    
    func setAccuracyLevelFor(aLocation: GPSLocalisation, accuracy: AccuracyLevel)
    {
        aLocation.myAccuracy = accuracy
    }
    
    

    func setInternetAP()
    {
        if Reachability.getWifiBSSID() != nil
        {
            self.internetAP = Reachability.getWifiBSSID()!
        }
        else
        {
            self.internetAP = "ND"
            print("No Wifi")
        }
    }
    
    
    
    func descriptionSession() -> String
    {
        guard let isOnGoing = isOnGoing else { return "" }  // Should not Happen
        
        if isOnGoing
        {
            return "Title : \(title ?? "")\nIn Progress : \(isOnGoing)\nStart Date : \(dateFormatter.string(from: startDate!))\nStart Bettery Level : \(startBatteryLevel)%\nInternetAP : \(internetAP)\nLocalisation num : \(triggerdLocs.count)"
        }

        return "Title : \(title ?? "")\nIn Progress : \(isOnGoing)\nStart Date : \(dateFormatter.string(from: startDate!))\nStart Bettery Level : \(startBatteryLevel)%\nEnd Date : \(dateFormatter.string(from: endDate!))\nEnd Battery Level : \(endBatteryLevel)%\nSession Duration : \(duration!) sec\nInternetAP : \(internetAP)\nLocalisation num : \(triggerdLocs.count)"
    }
}

