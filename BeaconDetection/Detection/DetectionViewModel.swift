//
//  DetectionViewModel.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/09/19.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import CoreLocation
import RxDataSources
import RxSwift

struct DetectionInfoListData {
    var beacon: CLBeacon
}

extension DetectionInfoListData: Equatable {
    static func == (lhs: DetectionInfoListData, rhs: DetectionInfoListData) -> Bool {
        return lhs.beacon == rhs.beacon
    }
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

extension SectionDetectionInfoListData: Equatable {
    static func == (lhs: SectionDetectionInfoListData, rhs: SectionDetectionInfoListData) -> Bool {
        return lhs.header == rhs.header && lhs.items == rhs.items
    }
}

class DetectionViewModel: NSObject {
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionDetectionInfoListData>()
    
    private let rangingButtonIconVar: Variable<UIImage> = Variable(#imageLiteral(resourceName: "RangingButtonIconStart"))
    private let statusVar = Variable("")
    private let inputProximityUUIDVar = Variable("")
    private let inputMajorVar = Variable("")
    private let inputMinorVar = Variable("")
    
    var rangingButtonIcon: Observable<UIImage> { return rangingButtonIconVar.asObservable() }
    var status: Observable<String> { return statusVar.asObservable() }
    var inputProximityUUID: Observable<String> { return inputProximityUUIDVar.asObservable() }
    var inputMajor: Observable<String> { return inputMajorVar.asObservable() }
    var inputMinor: Observable<String> { return inputMinorVar.asObservable() }
    
    private var manager: CLLocationManager?
    private var beaconRegion: CLBeaconRegion?
    
    private let sectionsVar = Variable<[SectionDetectionInfoListData]>([SectionDetectionInfoListData(header: "Info", items: [])])
    var sections: Observable<[SectionDetectionInfoListData]> { return sectionsVar.asObservable() }
    
    private var isRanging = false
    
    override init() {
        super.init()
        
        updateProximityUUIDToUserDefault()
        settingDetectionInfoTable()
        settingBeaconManager()
    }
    
    // MARK: - Tools
    
    func updateProximityUUIDToUserDefault() {
        guard let uuidString = UserDefaults.standard.string(forKey: Const.kProximityUUIDStringUserDefaultKey) else { return }
        inputProximityUUIDVar.value = uuidString
    }
    
    func updateProximityUUID(uuidText: String) {
        
        inputProximityUUIDVar.value = uuidText
        
        guard UUID(uuidString: uuidText) != nil else { return }
        UserDefaults.standard.set(uuidText, forKey: Const.kProximityUUIDStringUserDefaultKey)
    }
    
    func updateInputMajor(text: String) {
        inputMajorVar.value = int16RangeRestriction(text: text)
    }
    
    func updateInputMinor(text: String) {
        inputMinorVar.value = int16RangeRestriction(text: text)
    }
    
    func clearSections() {
        sectionsVar.value = [SectionDetectionInfoListData(header: "Info", items: [])]
    }
    
    func changeRanging() {
        
        if isRanging {
            stopRanging()
        } else {
            startRanging()
        }
    }
    
    func reSettingBeaconManager() {
        
        stopRanging()
        settingBeaconManager()
    }
    
    private func startRanging() {
        
        if !isMonitoringCapable() {
            statusVar.value = "Disabled monitoring"
            return
        }
        
        guard let beaconRegion = beaconRegion,
            authorizationStatusCheck() else { return }
        rangingButtonIconVar.value = #imageLiteral(resourceName: "RangingButtonIconPause")
        isRanging = true
        guard let manager = manager else { return }
        manager.startRangingBeacons(in: beaconRegion)
    }
    
    private func stopRanging() {
        guard let beaconRegion = beaconRegion else { return }
        rangingButtonIconVar.value = #imageLiteral(resourceName: "RangingButtonIconStart")
        isRanging = false
        guard let manager = manager else { return }
        manager.stopRangingBeacons(in: beaconRegion)
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
        manager = CLLocationManager()
        beaconRegion = toUseBeaconRegion()
        guard let manager = manager,
            authorizationStatusCheck(),
            let beaconRegion = beaconRegion else { return }
        manager.delegate = self
        manager.startMonitoring(for: beaconRegion)
        rangingButtonIconVar.value = #imageLiteral(resourceName: "RangingButtonIconPause")
    }
    
    private func toUseBeaconRegion() -> CLBeaconRegion! {
        
        guard let uuid = UUID(uuidString: inputProximityUUIDVar.value) else { return nil }
        
        if inputMajorVar.value.isEmpty {
            return CLBeaconRegion(proximityUUID: uuid, identifier: Const.kDefaultRegionIdentifier)
        }
        
        let majorNum = NSNumber(value: Int(inputMajorVar.value)!)
        
        if inputMinorVar.value.isEmpty {
            return CLBeaconRegion(proximityUUID: uuid,
                                  major: CLBeaconMajorValue(truncating: majorNum),
                                  identifier: Const.kDefaultRegionIdentifier)
        }
        
        let minorNum = NSNumber(value: Int(inputMinorVar.value)!)
        
        return CLBeaconRegion(proximityUUID: uuid,
                              major: CLBeaconMajorValue(truncating: majorNum),
                              minor: CLBeaconMinorValue(truncating: minorNum),
                              identifier: Const.kDefaultRegionIdentifier)
    }
    
    private func authorizationStatusCheck() -> Bool {
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            manager?.requestAlwaysAuthorization()
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
        
        switch proximity {
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
    
    private func int16RangeRestriction(text: String) -> String {
        
        var intText = ""
        
        for character in text {
            guard Int(String(character)) != nil else { continue }
            intText.append(character.description)
        }
        
        if let int: Int = Int(intText) {
            if text.count > String(INT16_MAX).count {
                return String(text.prefix(5))
            } else if int < 0 {
                return 0.description
            } else if int >= INT16_MAX {
                return INT16_MAX.description
            }
        }
        return intText
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
        
        switch state {
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
        guard region?.isKind(of: CLBeaconRegion.self) != nil else { return }
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
            
            sectionsVar.value[0].items.insert(DetectionInfoListData(beacon: beacon), at: 0)
            statusVar.value = convertProximityStatusToText(proximity: beacon.proximity)
            
            guard sectionsVar.value[0].items.count > Const.kDetectionInfosMaxNum else { continue }
            sectionsVar.value[0].items.removeLast()
        }
    }
}
