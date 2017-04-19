import UIKit
import MapKit
import CoreLocation
import SCLAlertView


class WelcomeVC: UIViewController
{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var idTextfield: UITextField!
    @IBOutlet weak var sessionSwitch: UISwitch!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    let defaults = UserDefaults.standard    // Local Storage infos about Timer for ongoing session
    var seconde: Double = 0
    var timer = Timer()

    // Singleton Instances (Session + Location)
    lazy var sessionsManager = { return SessionModelController.sessionSharedInstance }()
    lazy var locationManager = { return LocationManager.sharedInstance }()

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        UIDevice.current.isBatteryMonitoringEnabled = true  // Allow batery Monitoring
        idTextfield.delegate = self         // Set TextField Delegate
        locationManager.delegate = self     // Set LocationManager Delegate
        //mapView.delegate = self             // Set MapView Delegate
        self.hideKeyboardWhenTappedAround() // Hide Keyboard when tapping in the view
        
        // Monitor when User End editing TextField
        idTextfield.addTarget(self, action: #selector(WelcomeVC.textFieldDidChange), for: UIControlEvents.editingDidEnd)
        
        startApplicationStateObservation()  // Monitor App States changement

        if defaults.bool(forKey: "timerIsOn")
        {
            if sessionsManager.checkForActiveSession() { print("Check Active Session OK") }
            handleWelcomeAlert()
        }
    }
    
    

    // Manage Welcome pop-up alert when the app was previously stopped while a session was running
    func handleWelcomeAlert()
    {
        /* TIME INTERVAL CALCULAITONS - MAYBE NOT ACCURATE
        let startDate = dateFormatter.date(from: defaults.string(forKey: "timestamp")!)
        let endDate = Date()
        let calendar = NSCalendar.current
        let datecomponenets = calendar.dateComponents([.day, .hour, .minute, .second], from: startDate!, to: endDate)
        let seconds = datecomponenets.second */

        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        let alertView = SCLAlertView(appearance: appearance)
        
        alertView.addButton("Reprendre Session")
        {
            //self.seconde = Int(seconds!) + Int(self.defaults.string(forKey: "timerValue")!)!
            self.seconde = Double(self.defaults.string(forKey: "timerValue")!)!
            self.timerLabel.text = self.stringFromTimeInterval(interval: self.seconde)
            self.sessionSwitch.isOn = true
            self.startTmer()
        }
        
        alertView.addButton("Stocker Session")
        {
            print("Second button tapped")
            self.defaults.set(false, forKey: "timerIsOn")
            
            /* SAVE SESSION IN MODEL BUT NOT RELAUNCH IT (Timer 00:00:00) */
        }
        
        alertView.addButton("Annuler Session")
        {
            print("Third Button Tapped")
            self.defaults.set(false, forKey: "timerIsOn")
            
            /* DELETE SESSION IN MODEL */
        }
        
        alertView.showWarning("Informations", subTitle: "Lorsque vous avez quitté l'pplication une session de \(self.stringFromTimeInterval(interval: Double(self.defaults.string(forKey: "timerValue")!)!)) était en cours, souhaitez-vous ?")
    }
    
    
    // Call when start Timer - Create a Session instance
    func startSession() -> Bool
    {
        let aSession = Session(titleSession: "", isOnGoing: true)
        
        if checkTextField() // Check textField input datas
        {
            aSession.setTitle(titleSession: idTextfield.text!)  // Assign textfield text to Session Title
        }
        
        if checkBatteryLevel(level: batteryLevel)  // baterry level is usable
        {
            aSession.setBatteryLevel(onStart: true, level: String(format: "%.2f", batteryLevel!))
        }
        
        if sessionsManager.add(session: aSession)
        {
            return true
        }
        return false
    }
    
    
    // Call when stop Timer - Fill Session instance with last infos
    func stopSession(aSession: Session) -> Bool
    {
        print("INFOS FOR CURRENT SESSION :  \(sessionsManager.getSessionInfos(aSession: aSession))")

        if sessionsManager.stopOngoing(session: aSession)
        {
            return true
        }
        return false
    }

    
    // Check Session Title Textfield before adding it to Session Model
    func checkTextField() -> Bool
    {
        if idTextfield.hasText
        {
            return true
        }
        return false
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let backItem = UIBarButtonItem()
        backItem.title = "Retour"
        navigationItem.backBarButtonItem = backItem // Will show in the next view controller being pushed
    }
}



/* Timer Methods */
extension WelcomeVC
{
    func startTmer()
    {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(counter), userInfo: nil, repeats: true)
        
        if startSession()
        {
            print("Start Session OK")
        }
        else    // Add new Session Failed
        {
            SCLAlertView().showError("Attention!", subTitle: "Une erreur est survenue lorsque vous avez tenté de démarrer une nouvelle session. Réessayer ultérieurement.")
        }
    }
    
    
    // Stop Timer for both case : Switch or Reset Button (onReset = true)
    func stopTimer(onReset: Bool)
    {
        timer.invalidate()
        seconde = 0
        timerLabel.text = "00:00:00:000"
        
        let onGoingSession = sessionsManager.getOnGoingSession()    // Get Current Session instance
        
        if onReset == false // Stop timer with Switch (the proper way)
        {
            guard let onGoingSession = onGoingSession else { return }  // Be sure to have a Session instance
            
            if sessionsManager.stopOngoing(session: onGoingSession) // handle ending of Ongoing Session
            {
                if stopSession(aSession: onGoingSession)    // handle stop session process
                {
                    print("Stop Ongoing Session Succesful")
                }
                else
                {
                    SCLAlertView().showError("Erreur", subTitle: "Une erreur s'est produite lors de l'arrêt d'une session, veuillez réessayer. Merci!")
                }
            }
        }
        else    // Reset current Session
        {
            guard let onGoingSession = onGoingSession else { return }  // Be sure to have a Session instance
            
            if sessionsManager.delete(session: onGoingSession)
            {
                print("Delete Session Succesful")
            }
            else
            {
                SCLAlertView().showError("Erreur", subTitle: "Une erreur s'est produite lors de la suppression d'une session, veuillez réessayer. Merci!")
            }
        }
    }
    
    
    // Timer method
    func counter()
    {
        seconde += 0.01
        timerLabel.text = stringFromTimeInterval(interval: seconde)
    }
    
    
    // Convert Timer Doulbe value in String Value for TimerLabel Text
    func stringFromTimeInterval(interval: Double) -> String
    {
        let time = NSInteger(interval)
        let ms = Int(interval.truncatingRemainder(dividingBy: 1) * 1000)
            
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
            
        return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
    }
}




/* Handle User Interactions with the View - ACTIONS */
extension WelcomeVC
{
    @IBAction func switchSession(_ sender: Any)
    {
        if sessionSwitch.isOn   // Start Timer
        {
            startTmer()
            mapView.showsUserLocation = true
            locationManager.startLocationUpdates()  // START LOCATION MANAGER UPDATES
        }
        else    // Stop Timer
        {
            locationManager.stopLocationUpdates()
            stopTimer(onReset: false)
        }
    }
    
    
    @IBAction func historySectionButtonPressed(_ sender: Any)
    {
        self.performSegue(withIdentifier: "goToDetailSession", sender: nil)
    }
    
    
    @IBAction func cameraButtonPressed(_ sender: Any)
    {
        // Handle camera access
    }
    
    
    @IBAction func resetCurrentSession(_ sender: Any)
    {
        if sessionSwitch.isOn
        {
            sessionSwitch.setOn(false, animated: true)
        }
        stopTimer(onReset: true)
    }
}



/* Handle Location Delegate methods */
extension WelcomeVC: LocationDelegate
{
    func didUpdateLocation(_ location: CLLocation, lastUpdated: Date, accuracy: Double)
    {
        print("Did Update To Location : \(dateFormatter.string(from: lastUpdated)) \(location.coordinate.latitude) \(location.coordinate.longitude) - Accuracy : \(accuracy)")
        
        if (sessionsManager.getOnGoingSession() != nil) // Be sure to have a valide Session instance
        {
            sessionsManager.storeTriggeredLocFor(session: sessionsManager.getOnGoingSession()!, location: location)
        }
        else { print("Unable to find Ongoing Session") }
    }
    
    
    func didFailWithError(_ error: NSError)
    {
        // CHANGE ALERT View TO CUSTOM SCALERTEVIEWCONTROLLER
        let alertController = UIAlertController(title: "Location updates failed", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action -> Void in
        }))
        alertController.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.default, handler: { action -> Void in
            self.locationManager.startLocationUpdates()
        }))
        present(alertController, animated: true) { () -> Void in }
    }
    
    
    func didChangeAuthStatus(_ status: CLAuthorizationStatus)
    {
        // Monitor Localisation permission
        print("Change auth status")
    }
}



/* Handle TextField Delegate Methods */
extension WelcomeVC: UITextFieldDelegate
{
    // Called when return key pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()    // Dismiss the keyboard
        return true;
    }
    
    
    func textFieldDidChange()
    {
        print("textField EDITING DID END")
        
        if idTextfield.hasText   // TextField not empty
        {
            if sessionsManager.checkForActiveSession()  // Check for Ongoig Session
            {
                // Set title to active question
                sessionsManager.getOnGoingSession()?.setTitle(titleSession: idTextfield.text!)
            }
        }
    }
}



/* Handle respones to Application State changement */
extension WelcomeVC
{
    func startApplicationStateObservation()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        // Test - monitor when app goes in foregorund
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    
    func appMovedToBackground()
    {
        print("App moved to background - Will resign Active")
        
        if sessionSwitch.isOn
        {
            defaults.set(true, forKey: "timerIsOn")
            defaults.set(seconde, forKey: "timerValue")    // Save Current Timer Value (Int seconds)
            defaults.set(getCurrentTimestamp(), forKey: "timestamp")    // Save current timestamp
        }
        else { defaults.set(false, forKey: "timerIsOn") }
    }
    
    
    func appMovedToForeground()
    {
        print("App moved to foregorund - Did Become Active")
        print("Switch was on : \(defaults.bool(forKey: "timerIsOn"))")
    }
}
