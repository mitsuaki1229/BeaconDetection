//
//  DetectionViewModel.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/07/29.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import CoreLocation

import INTULocationManager
import RxSwift

import AFNetworking
import SVProgressHUD

class DetectionViewModel: NSObject {
    
    private let statusVar = Variable("")
    private let proximityUUIDVar = Variable(UUID())
    private let majorVar = Variable(NSNumber())
    private let minorVar = Variable(NSNumber())
    private let accuracyVar = Variable(CLLocationAccuracy())
    private let rssiVar = Variable(0)
    
    var status: Observable<String> { return statusVar.asObservable() }
    var proximityUUID: Observable<UUID> { return proximityUUIDVar.asObservable() }
    var major: Observable<NSNumber> { return majorVar.asObservable() }
    var minor: Observable<NSNumber> { return minorVar.asObservable() }
    var accuracy: Observable<CLLocationAccuracy> { return accuracyVar.asObservable() }
    var rssi: Observable<Int> { return rssiVar.asObservable() }
    
    private var manager:CLLocationManager!
    private var beaconRegion:CLBeaconRegion?
    private var beacons:[CLBeacon]?
    
    override init() {
        super.init()
        
        // ビーコン用UUID設定
        guard let uuid = UUID(uuidString: Const.PROXIMITY_UUID) else {
            return
        }
        
        proximityUUIDVar.value = uuid
        beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "一意キー")
        
        manager = CLLocationManager()
        manager.delegate = self
        
        authorizationStatusCheck()
        
        // 検知開始
        manager.startMonitoring(for: beaconRegion!)
    }
    
    // MARK: - iBeacon
    
    /// 領域モニタリング開始
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("モニタリング開始")
        
        statusVar.value = "モニタリング開始"
        manager.requestState(for: region)
    }
    
    /// 領域モニタリング停止
    func locationManager(_ manager: CLLocationManager, didStopMonitoringForRegion region: CLRegion) {
        print("モニタリング停止")
        
        statusVar.value = "測定停止中"
    }
    
    // モニタリング結果判定
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        // リージョン判定
        switch (state) {
        case .inside:
            print("距離測定開始")
            statusVar.value = "距離測定開始"
            manager.startRangingBeacons(in: beaconRegion!)
        case .outside:
            print("距離測定対象外距離")
            statusVar.value = "距離測定対象外距離"
        default:
            print("不明")
            statusVar.value = "不明"
        }
    }
    
    // リージョン監視失敗
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("距離測定監視失敗")
        
        guard region?.isKind(of: CLBeaconRegion.self) != nil else {
            return
        }
        
        print("iBeacon測定判定失敗")
        statusVar.value = "測定失敗"
    }
    
    // 通信失敗
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("エラーコード:" + String(error._code))
        statusVar.value = "通信失敗 エラーコード:" + String(error._code)
    }
    
    // 領域内判定
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("距離内")
        statusVar.value = "測定距離内"
    }
    
    // 領域外判定
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("距離外")
        statusVar.value = "測定距離外"
    }
    
    // ビーコン確保
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        self.beacons = beacons
        
        for beacon in beacons {
            
            switch (beacon.proximity) {
            case .unknown:
                
                print("見つかりません")
                statusVar.value = "みつかりません"
                
                // 初期化しつつ戻る
                setBeaconResult(nil)
                
                return
                
            case .immediate:
                print("近くにあります: 50cm以内？")
                statusVar.value = "およそ50cm以内"
            case .near:
                print("わりと近くにあります: 50cm~6m?")
                statusVar.value = "およそ50cm~6mの範囲内"
            default:
                print("かなり遠いです: 6m~20m?")
                statusVar.value = "およそ6m~20mの範囲内"
            }
            
            // 情報出力
            // 識別子
            print(beacon.proximityUUID.uuidString)
            print(beacon.major)    // 16bit識別子
            print(beacon.minor)    // 16bit識別子
            // 電波情報
            print(beacon.accuracy) // 近接度精度
            print(beacon.rssi)     // 受信強度
            
            setBeaconResult(beacon)
            
            // 一番最初に取得したBeaconを表示
            return
        }
    }
    
    // MARK: - Public Method
    
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
    
    // 検知内容を送信する
    func sendBeaconDetectionData() {
        print("サーバ送信")
        
        // 送信前に検知を停止
        self.manager.stopMonitoring(for: beaconRegion!)
        
        // ローディング
        SVProgressHUD.show(withStatus: "通信中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        // 検出データ送信
        let postUrl = Const.DESTINATION_BASE_URL + Const.DESTINATION_API_ENDPOINT
        
        let manager = AFHTTPSessionManager()
        
        var param:Dictionary<String, String> = ["":""]
        param["proximityUUID"] = proximityUUIDVar.value.uuidString
        param["major"] = majorVar.value.stringValue
        param["minor"] = minorVar.value.stringValue
        param["accuracy"] = String(accuracyVar.value)
        param["rssi"] = String(rssiVar.value)
        
        setLocation(param: &param)
        
        manager .post(
            postUrl,
            parameters: param,
            progress: nil,
            success: { (operation, responseObject) in
                print("通信成功")
                SVProgressHUD.dismiss()
        },
            failure: { (operation, error) in
                print("通信失敗:" + String(describing: error))
                SVProgressHUD.dismiss()
        })
    }
    
    /// 位置情報サービス認証状態を確認する
    func authorizationStatusCheck() {
        
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
    
    // MARK: - Private Method
    
    /// ビーコンが使用できるか確認
    private func isMonitoringCapable() -> Bool {
        return CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self)
    }
    
    // 通知内容を設定する(nil == 初期化)
    private func setBeaconResult(_ beacon: CLBeacon?) {
        
        if let beacon = beacon {
            proximityUUIDVar.value = beacon.proximityUUID
            majorVar.value = beacon.major
            minorVar.value = beacon.minor
            accuracyVar.value = beacon.accuracy
            rssiVar.value = beacon.rssi
            
            return
        }
        
        proximityUUIDVar.value = UUID()
        majorVar.value = 0
        minorVar.value = 0
        accuracyVar.value = 0
        rssiVar.value = 0
    }
    
    /// 現在地情報を送信情報にセットする
    private func setLocation(param: inout Dictionary<String, String>) {
        
        guard CLLocationManager.authorizationStatus() == .authorizedAlways else {
            return
        }
        
        var currentAccuracyStr  = ""
        var currentLongitudeStr = ""
        var currentLatitudeStr  = ""
        
        var keepAlive = true
        
        let locMgr = INTULocationManager.sharedInstance()
        locMgr.requestLocation(withDesiredAccuracy: INTULocationAccuracy.city,
                               timeout: 10.0,
                               block: { (currentLocation:CLLocation!, achievedAccuracy:INTULocationAccuracy, status:INTULocationStatus) -> Void in
                                
                                switch (status) {
                                case .success:
                                    break
                                default:
                                    keepAlive = false
                                    return
                                }
                                
                                currentAccuracyStr = String(achievedAccuracy.rawValue)
                                
                                guard let currentLocation = currentLocation else {
                                    keepAlive = false
                                    return
                                }
                                
                                currentLongitudeStr = String(currentLocation.coordinate.longitude)
                                currentLatitudeStr = String(currentLocation.coordinate.latitude)
                                
                                keepAlive = false
        })
        
        let runLoop = RunLoop.current
        while keepAlive &&
            runLoop.run(mode: .defaultRunLoopMode, before: Date(timeIntervalSinceNow: 0.1)) {
                // 処理継続
        }
        
        param["currentAccuracy"] = currentAccuracyStr
        param["currentLongitude"] = currentLongitudeStr
        param["currentLatitude"] = currentLatitudeStr
    }
}

extension DetectionViewModel : CLLocationManagerDelegate {
    
}
