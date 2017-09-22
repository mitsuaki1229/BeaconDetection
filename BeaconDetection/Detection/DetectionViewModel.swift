//
//  DetectionViewModel.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/09/19.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import RxDataSources
import CoreLocation
import RxSwift

// TODO: Input text Check
enum BeaconOptionValidationResult {
    case ok(message: String)
    case empty
    case validating
    case failed(message: String)
}

extension BeaconOptionValidationResult {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

struct DetectionInfoListData {
    var beacon: CLBeacon
}

struct SectionDetectionInfoListData {
    var header: String
    var items: [Item]
}

extension SectionDetectionInfoListData: SectionModelType {
    
    typealias Item = DetectionInfoListData
    
    init(original: SectionDetectionInfoListData, items: [Item]) {
        self = original
        self.items = items
    }
}

class DetectionViewModel: NSObject {
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionDetectionInfoListData>()
    
    private let rangingButtonIconVar: Variable<UIImage> = Variable(UIImage(named: "RangingButtonIconPause")!)
    private let statusVar = Variable("")
    private let inputProximityUUIDVar = Variable(Const.kDefaultProximityUUIDString)
    private let inputMajorVar = Variable("")
    private let inputMinorVar = Variable("")
    
    var rangingButtonIcon: Observable<UIImage> { return rangingButtonIconVar.asObservable() }
    var status: Observable<String> { return statusVar.asObservable() }
    var inputProximityUUID: Observable<String> { return inputProximityUUIDVar.asObservable() }
    var InputMajor: Observable<String> { return inputMajorVar.asObservable() }
    var inputMinor: Observable<String> { return inputMinorVar.asObservable() }
    
    private var manager:CLLocationManager!
    private var beaconRegion:CLBeaconRegion?
    
    private let sectionsVar = Variable<[SectionDetectionInfoListData]>([SectionDetectionInfoListData(header: "Info", items: [])])
    var sections: Observable<[SectionDetectionInfoListData]> { return sectionsVar.asObservable() }
    
    var isRanging = false
    
    override init() {
        super.init()
        
        settingDetectionInfoTable()
        settingBeaconManager()
    }
    
    // MARK: - Tools
    
    // TODO: Input text Check -> reSettingBeaconManager And Save UUIDVar
    
    func updateProximityUUID(text: String) {
        inputProximityUUIDVar.value = text
    }
    
    func updateInputMajor(text: String) {
        inputMajorVar.value = text
    }
    
    func updateInputMinor(text: String) {
        inputMinorVar.value = text
    }
    
    func changeRanging() {
        
        if isRanging {
            stopRanging()
        } else {
            startRanging()
        }
    }
    
    private func startRanging() {
        
        guard isMonitoringCapable() else {
            self.statusVar.value = "Disabled monitoring"
            return
        }
        
        guard let beaconRegion = beaconRegion else {
            return
        }
        
        rangingButtonIconVar.value = UIImage(named: "RangingButtonIconStart")!
        isRanging = true
        self.manager.startRangingBeacons(in: beaconRegion)
    }
    
    private func stopRanging() {
        
        guard let beaconRegion = beaconRegion else {
            return
        }
        
        rangingButtonIconVar.value = UIImage(named: "RangingButtonIconPause")!
        isRanging = false
        self.manager.stopRangingBeacons(in: beaconRegion)
    }
    
    private func settingDetectionInfoTable() {
        
        dataSource.configureCell = { [unowned self] ds, tv, ip, item in
            let cell = tv.dequeueReusableCell(withIdentifier: "DetectionInfoTableViewCell") as? DetectionInfoTableViewCell
                ?? DetectionInfoTableViewCell(style: .default, reuseIdentifier: "DetectionInfoTableViewCell")
            
            cell.uuidLabel.text = item.beacon.proximityUUID.uuidString
            cell.majorLabel.text = item.beacon.major.stringValue
            cell.minorLabel.text = item.beacon.minor.stringValue
            cell.proximityLabel.text = self.convertProximityStatusToText(proximity: item.beacon.proximity)
            cell.accuracyLabel.text = String(item.beacon.accuracy)
            cell.rssiLabel.text = String(item.beacon.rssi)
            
            cell.selectionStyle = .none
            
            return cell
        }
        
        dataSource.titleForHeaderInSection = {ds, index in
            ds.sectionModels[index].header
        }
    }
    
    private func settingBeaconManager() {
        
        guard let uuid = UUID.init(uuidString: inputProximityUUIDVar.value) else {
            return
        }
        
        if !inputMajorVar.value.isEmpty {
            
            let majorNum = NSNumber.init(value: Int(inputMajorVar.value)!)
            
            if !inputMinorVar.value.isEmpty {
                
                let minorNum = NSNumber.init(value: Int(inputMinorVar.value)!)
                
                beaconRegion = CLBeaconRegion(proximityUUID: uuid,
                                              major: CLBeaconMajorValue(truncating: majorNum),
                                              minor: CLBeaconMinorValue(truncating: minorNum),
                                              identifier: Const.kDefaultRegionIdentifier)
            } else {
                
                beaconRegion = CLBeaconRegion(proximityUUID: uuid,
                                              major: CLBeaconMajorValue(truncating: majorNum),
                                              identifier: Const.kDefaultRegionIdentifier)
            }
        } else {
            beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: Const.kDefaultRegionIdentifier)
        }
        
        manager = CLLocationManager()
        manager.delegate = self
        
        guard authorizationStatusCheck() else {
            return
        }
        
        manager.startMonitoring(for: beaconRegion!)
    }
    
    private func reSettingBeaconManager() {
        
        stopRanging()
        settingBeaconManager()
    }
    
    private func authorizationStatusCheck() -> Bool {
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            manager.requestAlwaysAuthorization()
            statusVar.value = "Not determined"
            return false
        case .restricted:
            statusVar.value = "Restricted"
            return false
        case .denied:
            statusVar.value = "Denied"
            return false
        case .authorizedAlways:
            statusVar.value = "Always"
            return true
        case .authorizedWhenInUse:
            statusVar.value = "When in use"
            return true
        }
    }
    
    private func isMonitoringCapable() -> Bool {
        return CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self)
    }
    
    private func convertProximityStatusToText(proximity: CLProximity) -> String {
        
        switch (proximity) {
        case .unknown:
            return "Unknown"
        case .immediate:
            return "Immediate:0~50cm"
        case .near:
            return "Near:50cm~6m"
        case .far:
            return "Far:6m~20m"
        }
    }
    
    private func debugBeacon(beacon: CLBeacon) {
        
        print(beacon.proximityUUID.uuidString)
        print(beacon.major)
        print(beacon.minor)
        print(convertProximityStatusToText(proximity: beacon.proximity))
        print(beacon.accuracy)
        print(beacon.rssi)
    }
}

extension DetectionViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        statusVar.value = "Start monitoring"
        
        manager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didStopMonitoringForRegion region: CLRegion) {
        statusVar.value = "Stop monitoring"
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        switch (state) {
        case .inside:
            statusVar.value = "Inside region"
            startRanging()
        case .outside:
            statusVar.value = "Outside region"
        default:
            statusVar.value = "Unknown"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        
        guard region?.isKind(of: CLBeaconRegion.self) != nil else {
            return
        }
        
        statusVar.value = "Fail"
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        statusVar.value = "Fail error code:" + String(error._code)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        statusVar.value = "Enter region"
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        statusVar.value = "Exit region"
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        for beacon in beacons {
            
            sectionsVar.value[0].items.append(DetectionInfoListData(beacon: beacon))
            statusVar.value = convertProximityStatusToText(proximity: beacon.proximity)
            
            debugBeacon(beacon: beacon)
        }
    }
}
