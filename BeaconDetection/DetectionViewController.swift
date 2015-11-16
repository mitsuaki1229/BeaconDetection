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

    @IBOutlet weak var helpBtn: UIButton!

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
    var beacons:[CLBeacon]?

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
    
    // 領域モニタリング停止
    func locationManager(manager: CLLocationManager, didStopMonitoringForRegion region: CLRegion) {
        print("モニタリング停止")
        self.statusLabel.text = "測定停止中"
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


        if ((region?.isKindOfClass(CLBeaconRegion)) != nil) {
            print("iBeacon測定判定失敗")
            self.statusLabel.text = "測定失敗"
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
            self.beacons = nil
            return
        }

        // TODO: 複数対応
        // TODO: 確保した結果をテーブルにmajor,minorで振り分け、表示したい
        // TODO: 今のところ、最終結果のみ表示している
        self.beacons = beacons

        for i in 0..<self.beacons!.count {

            let beacon = self.beacons![i] as CLBeacon

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
    }

    // MARK: - Action
    
    // 送信ボタン
    @IBAction func sendBtnTouchUpInside(sender: UIButton) {
        print("送信ボタン押下")
        // ???: 現在地不可の場合、そもそもBeacon自体取得できないんだし、送信ボタン自体をdisableにしたほうがいいかな？
        // ???: 今のところ送信前にチェックしている
        sendBeaconDetectionData()
    }

    // Helpボタン
    @IBAction func helpBtnTouchUpInside(sender: UIButton) {
        print("help")
        let helpViewController = HelpViewController()
        helpViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        self.presentViewController(helpViewController, animated: true, completion: nil)
    }

    // 再検知ボタン
    @IBAction func retryBtnTouchUpInside(sender: UIButton) {
        print("再検知")
        if(!isMonitoringCapable()){
            // 実施可能ではない
            return
        }
        self.manager.startRangingBeaconsInRegion(self.beaconRegion!)
    }

    // 検知停止ボタン
    @IBAction func stopBtnTouchUpInside(sender: UIButton) {
        print("停止")
        self.manager.stopRangingBeaconsInRegion(self.beaconRegion!)
    }

    // MARK: - Tools

    // 検知内容を送信する
    func sendBeaconDetectionData() {
        print("サーバ送信")
        
        // ローディング
        SVProgressHUD.showWithStatus("通信中", maskType: SVProgressHUDMaskType.Clear)
        
        // 送信前に検知を停止
        self.manager.stopMonitoringForRegion(self.beaconRegion!)
        
        // 現在地の情報取得が取得できる場合、一緒に送信する
        var currentAccuracyStr:String
        currentAccuracyStr = ""
        var currentLongitudeStr:String
        currentLongitudeStr = ""
        var currentLatitudeStr:String
        currentLatitudeStr = ""

        if CLLocationManager.authorizationStatus() == .AuthorizedAlways {
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
                    
                    currentAccuracyStr = String(achievedAccuracy.rawValue)
                    print("currentAccuracy=" + currentAccuracyStr)
                    
                    if currentLocation != nil {

                        currentLongitudeStr = String(currentLocation.coordinate.longitude)
                        currentLatitudeStr = String(currentLocation.coordinate.latitude)

                        print("currentLongitude = " + currentLongitudeStr)
                        print("currentLatitude  = " + currentLatitudeStr)
                    }
            })
        } else {
            print("現在地使用不可")
        }

        // 検出データ送信
        let postUrl = Const.DESTINATION_BASE_URL + Const.DESTINATION_API_URL
        
        let manager = AFHTTPRequestOperationManager()
        
        var param:Dictionary<String, String> = ["":""]
        param["proximityUUID"] = self.proximityUUIDLabel.text!
        param["major"] = self.majorLabel.text!
        param["minor"] = self.minorLabel.text!
        param["accuracy"] = self.accuracyLabel.text!
        param["rssi"] = self.rssiLabel.text!

        param["currentAccuracy"] = currentAccuracyStr
        param["currentLongitude"] = currentLongitudeStr // ケイド
        param["currentLatitude"] = currentLatitudeStr   // イド

        manager.POST(postUrl, parameters:param,
            success:{(operation: AFHTTPRequestOperation!, responseObject:AnyObject) in
                print("通信成功")
                // ローディング
                SVProgressHUD.dismiss()
            },
            failure:{(operation: AFHTTPRequestOperation?, error:NSError) in
                print("通信失敗:" + String(error))
                // TODO: 情報送信失敗時処理
                // ローディング
                SVProgressHUD.dismiss()
        })
    }

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

    // 使用できるかチェック
    func isMonitoringCapable() -> Bool {
        if (!CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion)) {
            return false;
        }
        return true;
    }
}
