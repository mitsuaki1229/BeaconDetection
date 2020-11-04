//
//  SimulatorViewModel.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/08/01.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import CoreBluetooth
import CoreLocation
import RxCocoa
import RxSwift

enum SimulatorViewModelState {
    case normal
    case peripheralError
    case other
}

class SimulatorViewModel: NSObject {
    
    private let disposeBag = DisposeBag()
    
    private let statusVar = BehaviorRelay(value: SimulatorViewModelState.other)
    private let proximityUUIDVar = BehaviorRelay(value: UUID(uuidString: ""))
    private let majorVar = BehaviorRelay(value: NSNumber())
    private let minorVar = BehaviorRelay(value: NSNumber())

    var status: Observable<SimulatorViewModelState> { return statusVar.asObservable() }
    var proximityUUID: Observable<UUID?> { return proximityUUIDVar.asObservable() }
    var major: Observable<NSNumber> { return majorVar.asObservable() }
    var minor: Observable<NSNumber> { return minorVar.asObservable() }
    
    private var peripheralManager: CBPeripheralManager?
    
    override init() {
        super.init()
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    // MARK: Tools
    
    func updateStatusSignal() {
        statusVar.accept(statusVar.value)
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
        
        guard let uuidString = UserDefaults.standard.string(forKey: Const.kProximityUUIDStringUserDefaultKey),
            let uuid = UUID(uuidString: uuidString) else { return }

        proximityUUIDVar.accept(uuid)
        majorVar.accept(getRandomNum())
        minorVar.accept(getRandomNum())

        guard let peripheralManager = peripheralManager else { return }
        
        let beaconRegion
            = CLBeaconRegion(proximityUUID: proximityUUIDVar.value!,
                             major: CLBeaconMajorValue(truncating: majorVar.value),
                             minor: CLBeaconMinorValue(truncating: minorVar.value),
                             identifier: Const.kDefaultRegionIdentifier)
        let beaconPeripheralData: [String: AnyObject] = NSDictionary(dictionary: beaconRegion.peripheralData(withMeasuredPower: nil)) as! [String: AnyObject]
        peripheralManager.startAdvertising(beaconPeripheralData)

        statusVar.accept(.normal)
    }
    
    private func stopAdvertising() {
        guard let peripheralManager = peripheralManager else { return }
        peripheralManager.stopAdvertising()
    }
}

extension SimulatorViewModel: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if peripheral.state != .poweredOn {
            statusVar.accept(.peripheralError)
            return
        }
        startAdvertising()
    }
}
