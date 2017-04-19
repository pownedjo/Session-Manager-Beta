import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        print("Application Will Launch")
        
        let defaults = UserDefaults.standard
        print("Switch was on or not : \(defaults.bool(forKey: "timerIsOn"))")
        
        return true
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication)
    {
        print("Application Did eneter Background")
    }
}

