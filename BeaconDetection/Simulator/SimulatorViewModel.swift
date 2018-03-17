//
//  SimulatorViewModel.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/08/01.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import CoreBluetooth
import CoreLocation
import RxSwift

enum SimulatorViewModelState {
    case normal
    case peripheralError
    case other
}

class SimulatorViewModel: NSObject {
    
    private let disposeBag = DisposeBag()
    
    private let statusVar = Variable(SimulatorViewModelState.other)
    private let proximityUUIDVar = Variable(UUID())
    private let majorVar = Variable(NSNumber())
    private let minorVar = Variable(NSNumber())
    
    var status: Observable<SimulatorViewModelState> { return statusVar.asObservable() }
    var proximityUUID: Observable<UUID> { return proximityUUIDVar.asObservable() }
    var major: Observable<NSNumber> { return majorVar.asObservable() }
    var minor: Observable<NSNumber> { return minorVar.asObservable() }
    
    private var peripheralManager: CBPeripheralManager?
    
    override init() {
        super.init()
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    // MARK: Tools
    
    func updateStatusSignal() {
        statusVar.value = statusVar.value
    }
    
    func regenerateBeacon() {
        guard let peripheralManager = peripheralManager else { return }
        
        if peripheralManager.isAdvertising {
            stopAdvertising()
        }
        startAdvertising()
    }
    
    private func getRandomNum() -> NSNumber {
        return NSNumber(value: Int(arc4random_uniform(_:UInt32(INT16_MAX))))
    }
    
    private func startAdvertising() {
        
        guard let uuidString = UserDefaults.standard.string(forKey: "kProximityUUIDString"),
            let uuid = UUID(uuidString: uuidString) else { return }
        
        proximityUUIDVar.value = uuid
        majorVar.value = getRandomNum()
        minorVar.value = getRandomNum()
        
        guard let peripheralManager = peripheralManager else { return }
        
        let beaconRegion
            = CLBeaconRegion(proximityUUID: proximityUUIDVar.value,
                             major: CLBeaconMajorValue(truncating: majorVar.value),
                             minor: CLBeaconMinorValue(truncating: minorVar.value),
                             identifier: Const.kDefaultRegionIdentifier)
        let beaconPeripheralData: [String: AnyObject] = NSDictionary(dictionary: beaconRegion.peripheralData(withMeasuredPower: nil)) as! [String: AnyObject]
        peripheralManager.startAdvertising(beaconPeripheralData)
        
        statusVar.value = .normal
    }
    
    private func stopAdvertising() {
        guard let peripheralManager = peripheralManager else { return }
        peripheralManager.stopAdvertising()
    }
}

extension SimulatorViewModel: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if peripheral.state != .poweredOn {
            statusVar.value = .peripheralError
            return
        }
        startAdvertising()
    }
}
