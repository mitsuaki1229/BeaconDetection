//
//  DetectionViewModel.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/09/19.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import CoreLocation
import RxCocoa
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
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionDetectionInfoListData>(configureCell: {_, tableView, indexPath, _ in
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return cell
    })
    
    private let rangingButtonIconVar: BehaviorRelay<UIImage> = BehaviorRelay(value: #imageLiteral(resourceName: "RangingButtonIconStart"))
    
    private let statusVar = BehaviorRelay(value: "")
    private let inputProximityUUIDVar = BehaviorRelay(value: "")
    private let inputMajorVar = BehaviorRelay(value: "")
    private let inputMinorVar = BehaviorRelay(value: "")
    
    var rangingButtonIcon: Observable<UIImage> { return rangingButtonIconVar.asObservable() }
    var status: Observable<String> { return statusVar.asObservable() }
    var inputProximityUUID: Observable<String> { return inputProximityUUIDVar.asObservable() }
    var inputMajor: Observable<String> { return inputMajorVar.asObservable() }
    var inputMinor: Observable<String> { return inputMinorVar.asObservable() }
    
    private var manager: CLLocationManager?
    private var beaconRegion: CLBeaconRegion?
    
    private let sectionsVar = BehaviorRelay<[SectionDetectionInfoListData]>(value: [SectionDetectionInfoListData(header: "Info", items: [])])
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
        inputProximityUUIDVar.accept(uuidString)
    }
    
    func updateProximityUUID(uuidText: String) {
        
        inputProximityUUIDVar.accept(uuidText)
        
        guard UUID(uuidString: uuidText) != nil else { return }
        UserDefaults.standard.set(uuidText, forKey: Const.kProximityUUIDStringUserDefaultKey)
    }
    
    func updateInputMajor(text: String) {
        inputMajorVar.accept(int16RangeRestriction(text: text))
    }
    
    func updateInputMinor(text: String) {
        inputMinorVar.accept(int16RangeRestriction(text: text))
    }
    
    func clearSections() {
        sectionsVar.accept([SectionDetectionInfoListData(header: "Info", items: [])])
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
            statusVar.accept("Disabled monitoring")
            return
        }
        
        guard let beaconRegion = beaconRegion,
              authorizationStatusCheck() else { return }
        rangingButtonIconVar.accept(#imageLiteral(resourceName: "RangingButtonIconPause"))
        isRanging = true
        guard let manager = manager else { return }
        manager.startRangingBeacons(in: beaconRegion)
    }
    
    private func stopRanging() {
        guard let beaconRegion = beaconRegion else { return }
        rangingButtonIconVar.accept(#imageLiteral(resourceName: "RangingButtonIconStart"))
        isRanging = false
        guard let manager = manager else { return }
        manager.stopRangingBeacons(in: beaconRegion)
    }
    
    private func settingDetectionInfoTable() {
        
        dataSource.configureCell = { [unowned self] _, tv, _, item in
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
        rangingButtonIconVar.accept(#imageLiteral(resourceName: "RangingButtonIconPause"))
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
            statusVar.accept("Not determined")
            return false
        case .restricted:
            statusVar.accept("Restricted")
            return false
        case .denied:
            statusVar.accept("Denied")
            return false
        case .authorizedAlways:
            statusVar.accept("Always")
            return true
        case .authorizedWhenInUse:
            statusVar.accept("When in use")
            return true
        @unknown default:
            fatalError("not supported status")
        }
    }
    
    func isMonitoringCapable() -> Bool {
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
        @unknown default:
            fatalError("not supported proximity")
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
        statusVar.accept("Start monitoring")
        
        manager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didStopMonitoringForRegion region: CLRegion) {
        statusVar.accept("Stop monitoring")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        switch state {
        case .inside:
            statusVar.accept("Inside region")
            startRanging()
        case .outside:
            statusVar.accept("Outside region")
        default:
            statusVar.accept("Unknown")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        guard region?.isKind(of: CLBeaconRegion.self) != nil else { return }
        statusVar.accept("Fail")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        statusVar.accept("Fail error code:" + String(error._code))
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        statusVar.accept("Enter region")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        statusVar.accept("Exit region")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        for beacon in beacons {
            
            var values = sectionsVar.value
            values[0].items.insert(DetectionInfoListData(beacon: beacon), at: 0)
            sectionsVar.accept(values)
            
            statusVar.accept(convertProximityStatusToText(proximity: beacon.proximity))
            
            guard values[0].items.count > Const.kDetectionInfosMaxNum else { continue }
            
            values[0].items.removeLast()
            sectionsVar.accept(values)
        }
    }
}
