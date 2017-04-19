import UIKit
import CoreLocation
import MapKit

class SessionDetailVC: UIViewController, MKMapViewDelegate
{
    @IBOutlet weak var LocTableView: UITableView!
    @IBOutlet weak var infoSessionTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationPickerLabel: UILabel!

    var tableViewLocData = [GPSLocalisation]() // Array of GPSLocalisation to populate TableView
    lazy var sessionsManager = { return SessionModelController.sessionSharedInstance }()
    var detailSession: Session?   // Session to Display on DetailVC


    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mapView.delegate = self
        LocTableView.delegate = self
        LocTableView.dataSource = self
        LocTableView.tableFooterView = UIView()  // Hide empty cells in tableView
    }
    

    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        if let detailSession = detailSession    // Be sure to have a valide Session instance
        {
            infoSessionTextView.text = sessionsManager.getSessionInfos(aSession: detailSession)
            reloadLocalisationDatas()   // Grab datas to populate TableView

            if displayPinOnMap()           // Handle Loc Annotation on mapView
            {
                print("Display Pin OK")
            }
            else
            {
                // handle message or alerteView here (inform user)
                print("No Pin to Display")
            }
        }
        else
        {
            // Handle AlerteView here
            print("Unable to display Session infos")
        }
    }
    
    
    func reloadLocalisationDatas()
    {
        // Add if let condition or guard here
        tableViewLocData = sessionsManager.getGPSLocalisationFor(aSession: detailSession!)!
    }
    
    
    func displayPinOnMap() -> Bool
    {
        let locations = sessionsManager.getArrayOfTriggeredLocFor(session: detailSession!)
        if locations?.count == 0 { return false }   // Be sure locations is not empty

        var countLocations = 0   // Index of locations Array
            
        self.mapView.region = MKCoordinateRegion(center: (locations?[0].coordinate)!, span: MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006))
        
        // Create pins for the locations to display
        for loc in (locations?.enumerated())!
        {
            let pin = PinAnnotation.init(pinID: countLocations, title: basicLocationString(location: loc.element), subtitle: "Loc num : \(countLocations)", coordinate: loc.element.coordinate)
            
            self.mapView.addAnnotation(pin)
            countLocations += 1
        }
        return true
    }
    
    
    /* MAPKIT DELEGEATE METHOD */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if let annotation = annotation as? PinAnnotation
        {
            let identifier = "pin"  // Unique ID
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView
            {
                dequeuedView.annotation = annotation
                view = dequeuedView
            }
            else
            {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
            }
            
            if annotation.pinID == 0    // Show first recorded Location in Green color
            {
                view.pinTintColor = UIColor.green
            }
            return view
        }
        return nil
    }
    
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        // Get coordinates for the center of the mapView
        //self.locationPickerLabel.text = "\(mapView.centerCoordinate.latitude) - \(mapView.centerCoordinate.longitude)"
        
        self.locationPickerLabel.text = customLocationString(location: mapView.centerCoordinate)
    }
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        let selectedPin = view.annotation as? PinAnnotation  // Cast to PinAnnotation custom class
        
        // Highlight tableView row which contains given Localisation
        self.LocTableView.selectRow(at: IndexPath(row: (selectedPin?.pinID)!, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.middle)

        print("Annotation coord : \(view.annotation?.coordinate.latitude)")
    }
}


extension SessionDetailVC: UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tableViewLocData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locCellID")! as! LocalisationTableViewCell
        
        cell.LocDescriptionLabel.text = tableViewLocData[indexPath.row].descriptionLocation()
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {        
        /* TEST GEOCODING WHEN HIT TABLE VIEW ROW */
        print("Geocoded adress = \(tableViewLocData[indexPath.row].setLocationAdress())")
    }
}
