//
//  DetectionViewController.swift
//  BeaconDetection
//
//  Created by 伊原光明 on 2015/11/06.
//  Copyright © 2015年 Mitsuaki Ihara. All rights reserved.
//

import UIKit
import CoreLocation

class DetectionViewController: UIViewController, CLLocationManagerDelegate {

    // FIXME: 適当な値が入ってます。
    let proximityUUID = NSUUID(UUIDString: "AAAAAAAABBBBBBBBBB")
    var beaconRegion = CLBeaconRegion()

    var manager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // CLBeaconRegionを生成
        beaconRegion = CLBeaconRegion(proximityUUID: self.proximityUUID!, identifier: "一意キー的なもの？")

        // デリゲード設定
        manager.delegate = self

        // 位置情報サービス認証状態
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            print("使用許可")
        case .AuthorizedWhenInUse:
            print("iBeacon距離観測可能")
        case .Denied:
            print("使用拒否")
        case .NotDetermined:
            print("許可未済")
        default:
            // .Restricted
            print("機能制限")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // 領域モニタリング開始
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        print("モニタリング開始")
        manager.requestStateForRegion(region)
    }

    // モニタリング結果判定
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {

        // リージョン判定
        switch (state) {
        case .Inside:
            print("距離測定開始")
            manager.startRangingBeaconsInRegion(self.beaconRegion)
        case .Outside:
            print("距離測定対象外距離")
        default:
            // .Unknown
            print("不明")
        }
    }

    // リージョン監視失敗
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("距離測定監視失敗")
        // TODO: リトライ処理が必要？
        
    }

    // 通信失敗
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {

    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {

    }

    // ビーコン確保
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {

    }
}
