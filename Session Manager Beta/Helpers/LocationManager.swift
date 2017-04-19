import Foundation
import CoreLocation


/* Protocol for LocationManager - Mandatory mehtods to implement */
protocol LocationDelegate
{
    func didUpdateLocation(_ location: CLLocation, lastUpdated: Date, accuracy: Double)
    func didFailWithError(_ error: NSError)
    func didChangeAuthStatus(_ status: CLAuthorizationStatus)
}



/* Location Manager methods */
class LocationManager: NSObject
{
    static let sharedInstance = LocationManager()
    var delegate: LocationDelegate?
    
    fileprivate lazy var locationManager = { return CLLocationManager() }()
    fileprivate (set) var location: CLLocation = CLLocation()
    fileprivate (set) var accuracy: CLLocationAccuracy = 0.0
    fileprivate (set) var lastUpdated: Date = Date()

    
    override init()
    {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest   // Adapt location accuracy !
        locationManager.distanceFilter = 1    // Update Location every 3m changes
    }
    
    
    func startLocationUpdates()
    {
        print("Start location updates in LOCATION MANAGER CLASS")
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        case .denied, .restricted:
            locationManager.stopUpdatingLocation()
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
        }
    }
    
    
    func stopLocationUpdates()
    {
        locationManager.stopUpdatingLocation()
    }
}


/* Location Manager - Core Location DELEGATE METHODS */
extension LocationManager: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let location = locations.first
        {
            self.location = location
            self.lastUpdated = location.timestamp
            self.accuracy = location.horizontalAccuracy
            
            /* HANDLE ACCURACY CALCULATION */
            
            delegate?.didUpdateLocation(location, lastUpdated: location.timestamp, accuracy: location.horizontalAccuracy)
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        delegate?.didFailWithError(error as NSError)
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        switch status {
        case .notDetermined:
            // If status has not yet been determied, ask for authorization
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:    // If authorized when in use
            
            //locationManager.startUpdatingLocation()
            print("locationManager didChangeAuthStatus : AUTHORIZED WHEN IN USE")
            
            break
        case .authorizedAlways:   // If always authorized
            
            //locationManager.startUpdatingLocation()
            print("locationManager didChangeAuthStatus : AUTHORIZED ALWAYS")
            
            break
        case .restricted:
            // If restricted by e.g. parental controls. User can't enable Location Services
            
            print("locationManager didChangeAuthStatus : RESTRICTED")

            break
        case .denied:
            // If user denied your app access to Location Services, but can grant access from Settings.app
            // Should handle it through custom AlerteView
            
            print("locationManager didChangeAuthStatus : DENIED")
            break
        }
        
        delegate?.didChangeAuthStatus(status)
    }
}
