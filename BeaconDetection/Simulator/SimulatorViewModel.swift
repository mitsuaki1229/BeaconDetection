//
//  SimulatorViewModel.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/08/01.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import CoreLocation
import CoreBluetooth
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
    
    private var peripheralManager: CBPeripheralManager!
    private var isAdvertising = false
    
    override init() {
        super.init()
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    // MARK: Tools
    
    func updateStatusSignal() {
        statusVar.value = statusVar.value
    }
    
    func regenerateBeacon() {
        
        if isAdvertising {
            stopAdvertising()
        }
        startAdvertising()
    }
    
    private func getRandomNum() -> NSNumber {
        let randomNum: Int = Int(arc4random_uniform(_:UInt32(INT16_MAX)))
        return NSNumber(value: randomNum)
    }
    
    private func startAdvertising() {
        
        guard let uuidString = UserDefaults.standard.string(forKey: "kProximityUUIDString") else {
            return
        }
        
        guard let uuid = UUID(uuidString: uuidString) else {
            return
        }
        proximityUUIDVar.value = uuid
        majorVar.value = getRandomNum()
        minorVar.value = getRandomNum()
        
        let beaconRegion
            = CLBeaconRegion.init(proximityUUID: proximityUUIDVar.value,
                                  major: CLBeaconMajorValue(truncating: majorVar.value),
                                  minor: CLBeaconMinorValue(truncating: minorVar.value),
                                  identifier: Const.kDefaultRegionIdentifier)
        
        let beaconPeripheralData = NSDictionary(dictionary: beaconRegion.peripheralData(withMeasuredPower: nil))
        
        peripheralManager.startAdvertising(beaconPeripheralData as? [String : AnyObject])
        isAdvertising = true
        statusVar.value = .normal
    }
    
    private func stopAdvertising() {
        peripheralManager.stopAdvertising()
        isAdvertising = false
    }
}

extension SimulatorViewModel : CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        guard peripheral.state == .poweredOn else {
            statusVar.value = .peripheralError
            return
        }
        
        startAdvertising()
    }
}
