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
    
    private let statusVar = Variable("")
    private let inputProximityUUIDVar = Variable("")
    private let InputMajorVar = Variable("")
    private let inputMinorVar = Variable("")
    var status: Observable<String> { return statusVar.asObservable() }
    var inputProximityUUID: Observable<String> { return inputProximityUUIDVar.asObservable() }
    var InputMajor: Observable<String> { return InputMajorVar.asObservable() }
    var inputMinor: Observable<String> { return inputMinorVar.asObservable() }
    
    private var manager:CLLocationManager!
    private var beaconRegion:CLBeaconRegion?
    
    private let sectionsVar = Variable<[SectionDetectionInfoListData]>([SectionDetectionInfoListData(header: "Info", items: [])])
    var sections: Observable<[SectionDetectionInfoListData]> { return sectionsVar.asObservable() }
    
    override init() {
        super.init()
        
        settingDetectionInfoTable()
        settingBeaconManager()
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
        
        guard let uuid = UUID(uuidString: Const.kDefaultProximityUUIDString) else {
            return
        }
        
        inputProximityUUIDVar.value = uuid.uuidString
        beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "一意キー")
        
        manager = CLLocationManager()
        manager.delegate = self
        
        authorizationStatusCheck()
        
        // FIXME: 測定可能時に検知を始める
        manager.startMonitoring(for: beaconRegion!)
    }
    
    // MARK: - iBeacon
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        statusVar.value = "モニタリング開始"
        print(statusVar.value)
        
        manager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didStopMonitoringForRegion region: CLRegion) {
        statusVar.value = "測定停止中"
        print(statusVar.value)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        // Region determination
        switch (state) {
        case .inside:
            statusVar.value = "距離測定開始"
            manager.startRangingBeacons(in: beaconRegion!)
        case .outside:
            statusVar.value = "距離測定対象外距離"
        default:
            statusVar.value = "不明"
        }
        print(statusVar.value)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        
        guard region?.isKind(of: CLBeaconRegion.self) != nil else {
            return
        }
        
        statusVar.value = "測定失敗"
        print(statusVar.value)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        statusVar.value = "通信失敗 エラーコード:" + String(error._code)
        print(statusVar.value)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        statusVar.value = "測定距離内"
        print(statusVar.value)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        statusVar.value = "測定距離外"
        print(statusVar.value)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        for beacon in beacons {
            
            sectionsVar.value[0].items.append(DetectionInfoListData(beacon: beacon))
            statusVar.value = convertProximityStatusToText(proximity: beacon.proximity)
            
            debugBeacon(beacon: beacon)
        }
    }
    
    // MARK: - Tools
    
    // MARK: - Public
    
    func startRanging() {
        
        guard isMonitoringCapable() else {
            self.statusVar.value = "Beacon使用不可"
            return
        }
        
        guard let beaconRegion = beaconRegion else {
            return
        }
        
        self.manager.startRangingBeacons(in: beaconRegion)
    }
    
    func stopRanging() {
        
        guard let beaconRegion = beaconRegion else {
            return
        }
        self.manager.stopRangingBeacons(in: beaconRegion)
    }
    
    // MARK: - Private
    
    private func authorizationStatusCheck() {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            statusVar.value = "使用許可"
        case .authorizedWhenInUse:
            statusVar.value = "測定可能"
        case .denied:
            statusVar.value = "使用拒否"
        case .notDetermined:
            manager.requestAlwaysAuthorization()
            statusVar.value = "許可未済"
        default:
            statusVar.value = "機能制限"
        }
    }
    
    private func isMonitoringCapable() -> Bool {
        return CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self)
    }
    
    private func convertProximityStatusToText(proximity: CLProximity) -> String {
        
        switch (proximity) {
        case .unknown:
            return "みつかりません"
        case .immediate:
            return "およそ50cm以内"
        case .near:
            return "およそ50cm~6mの範囲内"
        case .far:
            return "およそ6m~20mの範囲内"
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
}

