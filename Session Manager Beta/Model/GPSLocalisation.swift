import UIKit
import CoreLocation


class GPSLocalisation: NSObject
{
    let timestamp: String   // Maybe Date format instead
    let location: CLLocation
    var address: String = "ND"  // Default (before geocoding)
    var myAccuracy: AccuracyLevel
    let geoCoder = CLGeocoder() // geocoding lat/long coordinates

    
    init(timestamp: String, location: CLLocation, myAccuracy: AccuracyLevel)
    {
        self.timestamp = timestamp
        self.location = location
        self.myAccuracy = myAccuracy
    }
    
    
    // Geocode lat/long coordinates to set address property
    func setLocationAdress()
    {
        geoCoder.reverseGeocodeLocation(self.location, completionHandler: { placemarks, error in
            
            guard let addressDict = placemarks?[0].addressDictionary else { return }    // Valid Dict
            
            /* Testing purposes : Print each key-value pair in a new row */
            addressDict.forEach { print($0) }
            
            // Print fully formatted address
            if let formattedAddress = addressDict["FormattedAddressLines"] as? [String]
            {
                print(formattedAddress.joined(separator: ", "))
                self.address = formattedAddress.joined(separator: ", ")
            }
            
            if let streetName = addressDict["Name"] as? String
            {
                print("Street Name = " + streetName)
            }
        })
    }
    
    
    
    func descriptionLocation() -> String
    {
        return "Time : \(timestamp) - Lat : \(location.coordinate.latitude as Double) - Long : \(location.coordinate.longitude as Double) - Precision : \(location.horizontalAccuracy as Double) Loc : \(myAccuracy.description())"
    }
}



/* User Appreciation for Location Accuracy */
enum AccuracyLevel
{
    case Average
    case Best
    case Worst
    
    func description() -> String
    {
        switch self {
        case .Average:
            return "Moyenne"
        case .Best:
            return "Meilleure"
        case .Worst:
            return "Moins bonne"
        }
    }
}
