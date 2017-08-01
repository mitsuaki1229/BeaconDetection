//
//  SimulatorViewModel.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/08/01.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import Foundation
import CoreLocation
import CoreBluetooth

class SimulatorViewModel: NSObject {
    
    var peripheralManager: CBPeripheralManager!
    
    override init() {
        super.init()
        
        print("SimulatorViewModel init")
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        print("peripheralManagerDidUpdateState")
        
        if peripheral.state != .poweredOn {
            print("Bluetoothがオフです")
            return;
        }
        
        let proximityUUID = NSUUID.init(uuidString: Const.PROXIMITY_UUID)
        
        let beaconRegion
            = CLBeaconRegion.init(proximityUUID: proximityUUID! as UUID,
                                  major: 1,
                                  minor: 1,
                                  identifier: "com.mycompany.myregion")
        
        let beaconPeripheralData = NSDictionary(dictionary: beaconRegion.peripheralData(withMeasuredPower: nil))

        peripheralManager.startAdvertising(beaconPeripheralData as? [String : AnyObject])
    }
}

extension SimulatorViewModel : CBPeripheralManagerDelegate {
}
