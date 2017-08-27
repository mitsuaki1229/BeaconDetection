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
import RxSwift
import RxCocoa

class SimulatorViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    private let proximityUUIDVar = Variable(UUID())
    private let majorVar = Variable(0)
    private let minorVar = Variable(0)
    private let identifierVar = Variable("")
    
    var proximityUUID: Observable<UUID> { return proximityUUIDVar.asObservable() }
    var major: Observable<Int> { return majorVar.asObservable() }
    var minor: Observable<Int> { return minorVar.asObservable() }
    var identifier: Observable<String> { return identifierVar.asObservable() }
    
    var peripheralManager: CBPeripheralManager!
    
    override init() {
        super.init()
        
        guard let uuid = UUID(uuidString: Const.PROXIMITY_UUID) else {
            return
        }
        proximityUUIDVar.value = uuid
        majorVar.value = 1
        minorVar.value = 2
        identifierVar.value = "UNIQUE"
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if peripheral.state != .poweredOn {
            print("Bluetooth off.")
            return;
        }
        
        let proximityUUID = NSUUID.init(uuidString: Const.PROXIMITY_UUID)
        
        let beaconRegion
            = CLBeaconRegion.init(proximityUUID: proximityUUID! as UUID,
                                  major: CLBeaconMajorValue(majorVar.value),
                                  minor: CLBeaconMinorValue(minorVar.value),
                                  identifier: identifierVar.value)
        
        let beaconPeripheralData = NSDictionary(dictionary: beaconRegion.peripheralData(withMeasuredPower: nil))

        peripheralManager.startAdvertising(beaconPeripheralData as? [String : AnyObject])
    }
}

extension SimulatorViewModel : CBPeripheralManagerDelegate {
}
