import Foundation
import SystemConfiguration.CaptiveNetwork

class Reachability
{
    /** METHOD TO CALL BEFORE SENDING REQUEST - Internet access good enough for sending HTTP request **/
    static func getWifiBSSID() -> String?
    {
        var bssid: String?
        
        if let interfaces = CNCopySupportedInterfaces() as NSArray?
        {
            for interface in interfaces
            {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary?
                {
                    // print("INTERFACE KEYS/VALUES : \(interfaceInfo.allKeys) - \(interfaceInfo.allValues)")
                    bssid = "\(interfaceInfo[kCNNetworkInfoKeyBSSID as String] as? String ?? "") - \(interfaceInfo[kCNNetworkInfoKeySSID as String] as? String ?? "")"
                    break
                }
            }
        }
        return bssid
    }
}

