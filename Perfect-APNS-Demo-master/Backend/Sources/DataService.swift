//
//  DataService.swift
//  Perfect-APNS
//
//  Created by Ryan Collins on 2/8/17.
//
//

import Foundation
import PerfectLib
import PerfectNotifications

class DataService {
    
    static let instance = DataService()
    
    var devices : [Device] {
        get {
            return [Device("d12c753c86bddb70876d62cb42f3b6da8bea587c931149407634390842d17ecf")]
        }
        set {
            self.devices = newValue
        }
    }
    
    func addDevice(withJSONRequest json: String?) -> String {
        var response = "{\"error\": \"An unknown error occured\"}"
        
        if let jsonStr = json {
            do {
                let dict = try jsonStr.jsonDecode() as! [String: Any]
                
                let token = dict["token"] ?? nil
                
                if let deviceToken = token as? String {
                    let device = Device(deviceToken)
                    
                    //Prevent Duplicates
                    if !devices.contains(device) {
                        devices.append(device)
                        response = "{\"success\": \"registered successfully\"}"
                        dump(device)
                    } else {
                        response = "{\"success\": \"already registered\"}"
                    }
                }
            } catch {
                print("Failed to add device token")
            }
        }
        
        return response
    }
    
    func notify(title: String, message: String) {
        
        var deviceTokens = [String]()
        
        for device in devices {
            deviceTokens.append(device.deviceToken)
        }
        
        let n = NotificationPusher(apnsTopic: notificationsAppId)
        n.pushAPNS(
            configurationName: notificationsAppId,
            deviceTokens: deviceTokens,
            notificationItems: [.alertTitle(title), .alertBody(message), .sound("default")]) {
                responses in
                print("\(responses)")
        }
    }
}
