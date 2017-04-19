import UIKit
import MapKit


class PinAnnotation: NSObject, MKAnnotation
{
    let pinID: Int!
    var title: String?
    var subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(pinID: Int, title: String, subtitle: String, coordinate: CLLocationCoordinate2D)
    {
        self.pinID = pinID
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }
    
    
    /*
    func setCoordinate(newCoordinate: CLLocationCoordinate2D)
    {
        self.coord = newCoordinate
    }*/
}
