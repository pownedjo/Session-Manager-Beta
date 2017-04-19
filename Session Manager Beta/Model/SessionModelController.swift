import UIKit
import CoreLocation

class SessionModelController: NSObject
{
    static let sessionSharedInstance = SessionModelController()
    var sessionsForUser: [Session]?
    var indexSession: Int = 0
    let calendar = NSCalendar.current

    
    override init()
    {
        print("Init Shared Instance Array Session")
        sessionsForUser = [Session]()   // Init ARRAY
    }
    
    
    // Add Session
    func add(session: Session) -> Bool
    {
        self.sessionsForUser?.append(session)
        return true
    }

    
    // Delete Session
    func delete(session: Session) -> Bool
    {
        if sessionsForUser != nil
        {
            for aSession in sessionsForUser!
            {
                if aSession == session     // Find corresponding Session
                {
                    indexSession = (sessionsForUser?.index(of: aSession))!   // Find its Index
                    sessionsForUser?.remove(at: indexSession)               // Remove from Array
                    return true
                }
            }
        }
        return false
    }
    
    
    
    // Return the Ongoing session - nil if no Ongoing session
    func getOnGoingSession() -> Session?
    {
        let session: Session? = nil
    
        if checkForActiveSession()
        {
            for session in sessionsForUser!
            {
                if session.isOnGoing == true
                {
                    return session
                }
            }
        }
        return session
    }
    
    
    // Return True if there is an Ongoing Session - False if not
    func checkForActiveSession() -> Bool
    {
        if sessionsForUser != nil
        {
            for session in sessionsForUser!
            {
                if session.isOnGoing == true
                {
                    return true
                }
            }
            return false
        }
        return false
    }
    
    
    
    func stopOngoing(session: Session) -> Bool
    {
        session.isOnGoing = false
        session.endDate = dateFormatter.date(from: getCurrentTimestamp())
        
        if checkBatteryLevel(level: batteryLevel)
        {
            session.endBatteryLevel = String(format: "%.2f", batteryLevel!)
        }
        
        let dateComponenets = calendar.dateComponents([.day, .hour, .minute, .second], from: session.startDate!, to: session.endDate!)
        
        session.duration = dateComponenets.second

        return true
    }
    
    
    // Set triggered Loc for a given Session
    func storeTriggeredLocFor(session: Session, location: CLLocation)
    {
        let newLoc = GPSLocalisation(timestamp: getCurrentTimestamp(), location: location, myAccuracy: .Average)    // Create GPSLocalisation Object
        
        session.triggerdLocs.append(newLoc)
    }
    
    
    func getGPSLocalisationFor(aSession: Session) -> [GPSLocalisation]?
    {
        var gpsLoc = [GPSLocalisation]()
        
        for loc in aSession.triggerdLocs
        {
            gpsLoc.append(loc)
        }
        return gpsLoc
    }
    
    
    func getArrayOfTriggeredLocFor(session: Session) -> [CLLocation]?
    {
        var locations = [CLLocation]()
        
        for loc in session.triggerdLocs
        {
            locations.append(loc.location)
        }
        return locations
    }
    
    
    // Change following method
    func getAllSessions() -> [Session]?
    {
        return sessionsForUser
    }
    
    
    // Session String Description
    func getSessionInfos(aSession: Session) -> String
    {
        return aSession.descriptionSession()
    }
    
    
    /* TESTING PURPOSES - MAY USE ANOTHER WAY FOR PERSISTENCE
    func checkSavedDatas()
    {
        let filemgr = FileManager.default
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0]
        dataFilePath = docsDir.appending("/data.archive")
        
        print("Archive path = \(dataFilePath)")
        
        if filemgr.fileExists(atPath: dataFilePath!)
        {
            // Unarchive ARRAY OF SESSION INSTEAD OF STRING
            let dataArray = NSKeyedUnarchiver.unarchiveObject(withFile: dataFilePath!) as! [String]
            print("ARRAY OF DATAS SAVED : \(dataArray)")
        }
        else { print("No Archive File to parse") }
    }
    
    
    func saveDatas()
    {
        let contactArray = [idTextfield.text, idTextfield.text, idTextfield.text]
        NSKeyedArchiver.archiveRootObject(contactArray, toFile: dataFilePath!)
        print("Save ARRAY OK")
    }*/
    
}
