import Foundation
import UIKit
import CoreLocation


var batteryLevel: Float? { return UIDevice.current.batteryLevel * 100 } // Battery level Float value


// Date formatter
var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy hh:mm:ss"
    return formatter
}()

var timeFormatter: DateFormatter = {
    let time_formatter = DateFormatter()
    time_formatter.dateFormat = "hh:mm:ss"
    return time_formatter
}()


// Get current Timestamp
func getCurrentTimestamp() -> String
{
    let nowDate = NSDate()
    return(dateFormatter.string(from: nowDate as Date))
}


// Check is bateery level is usable
func checkBatteryLevel(level: Float?) -> Bool
{
    guard let level = level else { return false }
    if level < 0 || level > 100 { return false }  // Battery level out of range
    else { return true }
}



// Basic Location String Format latitude/longitude
func basicLocationString(location : CLLocation) -> String
{
    let lat = String(format: "%.12f", location.coordinate.latitude)
    let lon = String(format: "%.12f", location.coordinate.longitude)
    return "\(lat) / \(lon)"
}


func customLocationString(location : CLLocationCoordinate2D) -> String
{
    // Lattitude formating
    var latSeconds = (location.latitude * 3600)
    let latDegrees = latSeconds / 3600
    latSeconds = abs(latSeconds.truncatingRemainder(dividingBy: 3600))
    let latMinutes = latSeconds / 60
    latSeconds = latSeconds.truncatingRemainder(dividingBy: 60)
    
    // Longitude formating
    var longSeconds = (location.longitude * 3600)
    let longDegrees = longSeconds / 3600
    longSeconds = abs(longSeconds.truncatingRemainder(dividingBy: 3600))
    let longMinutes = longSeconds / 60
    longSeconds = longSeconds.truncatingRemainder(dividingBy: 60)
    
    let lattiudeCustomString = "\(abs(latDegrees))°\(latMinutes)'\(latSeconds)\(latDegrees >= 0 ? "N" : "S")"
    //let lattiudeCustomString2 = String(format: "%.2f", abs(latDegrees))
    
    let longitudeCustomString = "\(abs(longDegrees))°\(longMinutes)'\(longSeconds)\(longDegrees >= 0 ? "E" : "W")"
    
    // Check decimal number
    return("\(lattiudeCustomString) - \(longitudeCustomString)")
}



/* Hide Keyboard when tape detected anywhere in the view */
extension UIViewController
{
    func hideKeyboardWhenTappedAround()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
