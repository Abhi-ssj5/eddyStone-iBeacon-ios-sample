//
//  ViewController.swift
//  NearbySample
//
//  Created by Paradox on 13/02/19.
//  Copyright © 2019 Abhijeet Choudhary. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications


class ViewController: UIViewController {
    
    @IBOutlet weak var lblStatus: UILabel!
    
    
    
    var locationManager:CLLocationManager?
    var beaconRegion:CLBeaconRegion?
    
    let beaconUUIDs:[String] = ["7cce965b-2ee8-493f-b665-ebd5fa0edfaa","420f259d-d6cb-4100-a495-b0cad3691dcb"] //uuid - 16 Bytes size
    let braodCastingBeaconIdentifier:String = "com.cbl.beacon" //namespace - 10 Bytes size
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Un-comment this code to use iBeacon code
        
        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()
        
        locationManager?.delegate = self

        if let uuid = UUID(uuidString: beaconUUIDs[0]) {
            beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: braodCastingBeaconIdentifier)
        }

        if let bRegion = beaconRegion {
            locationManager?.startMonitoring(for: bRegion)
            self.locationManager?.startRangingBeacons(in: bRegion)
        }
        
        
        //Google beacon implementation
        /*BeaconManager.sharedInstance.beaconFound = { [weak self] message in
            if let data = message?.content {
                self?.lblStatus.text = "Beacon found: " + (String(data: data, encoding: String.Encoding.utf8) ?? "No data")
            }
        }
        
        BeaconManager.sharedInstance.beaconLost = { [weak self] message in
            if let data = message?.content {
                self?.lblStatus.text = "Beacon lost: " + (String(data: data, encoding: String.Encoding.utf8) ?? "No data")
            }
        }*/
        
    }


}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let bRegion = beaconRegion {
            self.locationManager?.startRangingBeacons(in: bRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let bRegion = beaconRegion {
            self.locationManager?.stopRangingBeacons(in: bRegion)
        }
        debugPrint("iBeacon lost....")
        lblStatus.text = "iBeacon lost...."
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        if let foundBeacon = beacons.first {
            debugPrint("iBeacon found!!!!!!!!!!!")
            lblStatus.text = "iBeacon found:\n\(foundBeacon.proximityUUID.uuidString)"
            
            debugPrint(foundBeacon.proximityUUID.uuidString)
            
            let content = UNMutableNotificationContent()
            content.title = "iBeacon found !!!"
            content.body = "\(foundBeacon.proximityUUID.uuidString)"
            content.sound = .default
            
            let request = UNNotificationRequest(identifier: self.braodCastingBeaconIdentifier, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
}

