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
    
    fileprivate let  proximityUUIDVar = Variable("")
    fileprivate let majorVar = Variable(0)
    fileprivate let minorVar = Variable(0)
    fileprivate let identifierVar = Variable("")
    
    var proximityUUID: Observable<String> { return proximityUUIDVar.asObservable() }
    var major: Observable<Int> { return majorVar.asObservable() }
    var minor: Observable<Int> { return minorVar.asObservable() }
    var identifier: Observable<String> { return identifierVar.asObservable() }
    
    var peripheralManager: CBPeripheralManager!
    
    override init() {
        super.init()
        
        print("SimulatorViewModel init")
        
        proximityUUIDVar.value = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
        majorVar.value = 1
        minorVar.value = 2
        identifierVar.value = "UNIQUE"
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        print("peripheralManagerDidUpdateState")
        
        if peripheral.state != .poweredOn {
            print("Bluetoothがオフです")
            // TODO: 画面のどっかのラベルに値を通知する？
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
