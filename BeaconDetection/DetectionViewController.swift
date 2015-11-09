//
//  DetectionViewController.swift
//  BeaconDetection
//
//  Created by 伊原光明 on 2015/11/06.
//  Copyright © 2015年 : Ihara. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation

class DetectionViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var proximityUUIDLabel: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var minorLabel: UILabel!
    @IBOutlet weak var accuracyLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    
    @IBOutlet weak var sendBtn: UIButton!

    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var StopBtn: UIButton!

    var proximityUUID:NSUUID?
    var beaconRegion:CLBeaconRegion?
    var manager:CLLocationManager!
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // レイアウト設定
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "monitoring_background")!)

        // 初期化
        setBeaconResult(nil)

        // ビーコン用UUID設定
        self.proximityUUID = NSUUID(UUIDString: Const.PROXIMITY_UUID)!
        self.beaconRegion = CLBeaconRegion(proximityUUID: self.proximityUUID!, identifier: "一意キー")

        self.manager = CLLocationManager()
        self.manager.delegate = self

        // 位置情報サービス認証状態
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            print("使用許可")
            self.statusLabel.text = "使用許可"
        case .AuthorizedWhenInUse:
            print("iBeacon距離観測可能")
            self.statusLabel.text = "測定可能"
        case .Denied:
            print("使用拒否")
            self.statusLabel.text = "使用拒否"
        case .NotDetermined:
            print("許可未済")
            // 認証要求
            self.manager.requestAlwaysAuthorization()
            self.statusLabel.text = "許可未済"
        default:
            print("機能制限")
            self.statusLabel.text = "機能制限"
        }

        // 検知開始
        // TODO: 2度目以降は手動で実施出来るようにしたい
        self.manager.startMonitoringForRegion(self.beaconRegion!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        // 縦画面固定
        return UIInterfaceOrientationMask.Portrait
    }

    // MARK: - iBeacon
    
    // 領域モニタリング開始
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        print("モニタリング開始")
        self.statusLabel.text = "モニタリング開始"
        manager.requestStateForRegion(region)
    }
    
    // モニタリング結果判定
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        
        // リージョン判定
        switch (state) {
        case .Inside:
            print("距離測定開始")
            self.statusLabel.text = "距離測定開始"
            manager.startRangingBeaconsInRegion(self.beaconRegion!)
        case .Outside:
            print("距離測定対象外距離")
            self.statusLabel.text = "距離測定対象外距離"
        default:
            print("不明")
            self.statusLabel.text = "不明"
        }
    }
    
    // リージョン監視失敗
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("距離測定監視失敗")
        self.statusLabel.text = "測定失敗"

        if ((region?.isKindOfClass(CLBeaconRegion)) != nil) {
            print("リトライしたい")
            // TODO: リトライ処理が必要
            // TODO: 再実行までに数秒の待ちを実施させる
            // TODO: 試行回数を画面に表示させる
        }
    }
    
    // 通信失敗
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("エラーコード:" + String(error.code))
        self.statusLabel.text = "通信失敗 エラーコード:" + String(error.code)
    }
    
    // 領域内判定
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("距離内")
        self.statusLabel.text = "測定距離内"
    }
    
    // 領域外判定
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("距離外")
        self.statusLabel.text = "測定距離外"
    }
    
    // ビーコン確保
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        
        if beacons.count == 0 {
            print("見つかりません:0")
            return
        }
        
        let beacon = beacons[0] as CLBeacon
        
        switch (beacon.proximity) {
        case .Unknown:
            print("見つかりません")
            self.statusLabel.text = "みつかりません"
            // 結果初期化
            setBeaconResult(nil)
        case .Immediate:
            print("近くにあります: 50cm以内？")
            self.statusLabel.text = "およそ50cm以内"
        case .Near:
            print("わりと近くにあります: 50cm~6m?")
            self.statusLabel.text = "およそ50cm~6mの範囲内"
        default:
            print("かなり遠いです: 6m~20m?")
            self.statusLabel.text = "およそ6m~20mの範囲内"
        }

        // 情報出力
        // 識別子
        print(beacon.proximityUUID.UUIDString)
        print(beacon.major)    // 16bit識別子
        print(beacon.minor)    // 16bit識別子
        // 電波情報
        print(beacon.accuracy) // 近接度精度
        print(beacon.rssi)     // 受信強度
        
        setBeaconResult(beacon)
    }
    
    // MARK: - Action
    
    // 送信ボタン
    @IBAction func sendBtnTouchUpInside(sender: UIButton) {
        print("サーバ送信")
        // TODO: 一旦検知を止める
        
        // 現在地の情報取得
        // TODO: 同時にサーバに送信する？
        let locMgr = INTULocationManager.sharedInstance()
        locMgr.requestLocationWithDesiredAccuracy(INTULocationAccuracy.City,
            timeout: 10.0,
            block: { (currentLocation:CLLocation!, achievedAccuracy:INTULocationAccuracy, status:INTULocationStatus) -> Void in
                
                switch (status) {
                case .Success:
                    print("success")
                case .TimedOut:
                    print("timeout")
                default:
                    print("default")
                }
                print("accuracy=" + String(achievedAccuracy.rawValue))
                print("location=" + currentLocation.description)
        })

        // 送信準備
        // データを設定する
        let postStr = "proximityUUID=" + self.proximityUUIDLabel.text! +
            "&major=" + self.majorLabel.text! +
            "&minor=" + self.minorLabel.text! +
            "&accuracy=" + self.accuracyLabel.text! +
            "&rssi=" + self.rssiLabel.text!

        let postUrl = Const.DESTINATION_BASE_URL + Const.DESTINATION_API_URL
        let url = NSURL(string: postUrl)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"

        let postData = postStr.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPBody = postData
        
        let shareSession = NSURLSession.sharedSession()
        let sessionTask = shareSession.dataTaskWithRequest(request)
        
        // 送信
        sessionTask.resume()
        
        // TODO: 送信結果表示
        // TODO: 検知を再実行するか、再実行ボタンを実装する
    }

    // 再検知ボタン
    @IBAction func retryBtnTouchUpInside(sender: UIButton) {
        print("再検知")
        // TODO: 今実行しているかの確認が必要?
        self.manager.startMonitoringForRegion(self.beaconRegion!)
    }

    // 検知停止ボタン
    @IBAction func stopBtnTouchUpInside(sender: UIButton) {
        print("停止")
        // TODO: 今実行していないかの確認が必要?
        self.manager.stopMonitoringForRegion(self.beaconRegion!)
    }

    // MARK: - Tools
    
    // 通知内容を設定する(nil == 初期化)
    func setBeaconResult(beacon: CLBeacon?) {
        
        // 表示設定
        if beacon == nil {
            self.proximityUUIDLabel.text = ""
            self.majorLabel.text = ""
            self.minorLabel.text = ""
            self.accuracyLabel.text = ""
            self.rssiLabel.text = ""
        } else {
            self.proximityUUIDLabel.text = beacon!.proximityUUID.UUIDString
            self.majorLabel.text = "\(beacon!.major)"
            self.minorLabel.text = "\(beacon!.minor)"
            self.accuracyLabel.text = "\(beacon!.accuracy)"
            self.rssiLabel.text = "\(beacon!.rssi)"
        }
    }
}
