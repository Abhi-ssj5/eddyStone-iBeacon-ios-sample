//
//  BeaconManager.swift
//  NearbySample
//
//  Created by Paradox on 26/02/19.
//  Copyright © 2019 Abhijeet Choudhary. All rights reserved.
//



import UIKit
import Foundation

typealias BeaconMessageCallback = (GNSMessage?)->()

class BeaconManager: NSObject {
    
    private var subscription:GNSSubscription?
    private static let googleApiKey:String = "<google api key>"
    
    static let sharedInstance = {
       return BeaconManager()
    }()
    
    var beaconFound:BeaconMessageCallback?
    var beaconLost:BeaconMessageCallback?
    
    //MARK: - Setup Subscription
    func setup(logging:Bool = true, apiKey:String = BeaconManager.googleApiKey) {
        GNSMessageManager.setDebugLoggingEnabled(logging)
        
        let messageManager = GNSMessageManager(apiKey: apiKey, paramsBlock: { (params) in
            params?.bluetoothPermissionErrorHandler = { hasError in
                if hasError {
                    debugPrint("Nearby works better if Bluetooth use is allowed")
                }
            }
            
            params?.bluetoothPowerErrorHandler = { hasError in
                if hasError {
                    debugPrint("Nearby works better if Bluetooth is turned on")
                }
            }
        })
        
        _ = GNSPermission.init { (bool) in
            debugPrint("permission \(bool ? "" : "not") granted")
        }
        
        let strategy = GNSBeaconStrategy { (params) in
            params?.includeIBeacons = true
            params?.allowInBackground = true
        }
        
        let messageFoundHandler:GNSMessageHandler = { [weak self] message in
            debugPrint("===========beacon found alert===========")
            if let safeValue = message?.content { debugPrint(String(data: safeValue, encoding: String.Encoding.utf8) ?? "no data") }
            self?.beaconFound?(message)
        }
        
        let messageLostHandler:GNSMessageHandler = { [weak self] message in
            debugPrint("===========beacon lost alert===========")
            self?.beaconLost?(message)
        }
        
        subscription = messageManager?.subscription(messageFoundHandler: messageFoundHandler, messageLostHandler: messageLostHandler, paramsBlock: { (params) in
            params?.deviceTypesToDiscover = .bleBeacon
            params?.beaconStrategy = strategy
        })
    }
    
}
