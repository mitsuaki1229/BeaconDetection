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
    private let identifierVar = Variable("UNIQUE")
    
    var status: Observable<SimulatorViewModelState> { return statusVar.asObservable() }
    var proximityUUID: Observable<UUID> { return proximityUUIDVar.asObservable() }
    var major: Observable<NSNumber> { return majorVar.asObservable() }
    var minor: Observable<NSNumber> { return minorVar.asObservable() }
    var identifier: Observable<String> { return identifierVar.asObservable() }
    
    private var peripheralManager: CBPeripheralManager!
    
    override init() {
        super.init()
        
        guard let uuid = UUID(uuidString: Const.PROXIMITY_UUID) else {
            return
        }
        proximityUUIDVar.value = uuid
        majorVar.value = getRandomNum()
        minorVar.value = getRandomNum()
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    // MARK: CBPeripheralManagerDelegate
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        guard peripheral.state == .poweredOn else {
            statusVar.value = .peripheralError
            return;
        }
        
        statusVar.value = .normal
        
        let proximityUUID = NSUUID.init(uuidString: Const.PROXIMITY_UUID)
        
        let beaconRegion
            = CLBeaconRegion.init(proximityUUID: proximityUUID! as UUID,
                                  major: CLBeaconMajorValue(truncating: majorVar.value),
                                  minor: CLBeaconMinorValue(truncating: minorVar.value),
                                  identifier: identifierVar.value)
        
        let beaconPeripheralData = NSDictionary(dictionary: beaconRegion.peripheralData(withMeasuredPower: nil))
        
        peripheralManager.startAdvertising(beaconPeripheralData as? [String : AnyObject])
    }
    
    // MARK: Tools
    
    private func getRandomNum() -> NSNumber {
        let randomNum: Int = Int(arc4random_uniform(10)) + 1
        return NSNumber(value: randomNum)
    }
}

extension SimulatorViewModel : CBPeripheralManagerDelegate {
}
