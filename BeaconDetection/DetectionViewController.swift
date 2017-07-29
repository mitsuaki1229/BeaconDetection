//
//  DetectionViewController.swift
//  BeaconDetection
//
//  Created by 伊原光明 on 2015/11/06.
//  Copyright © 2015年 : Ihara. All rights reserved.
//

import UIKit
import CoreLocation
import SVProgressHUD
import AFNetworking

class DetectionViewController: UIViewController {
    
    var proximityUUID:UUID?
    var beaconRegion:CLBeaconRegion?
    var manager:CLLocationManager!
    var beacons:[CLBeacon]?
    let viewModel = DetectionViewModel()

    // MARK: -
    
    override func loadView() {
        self.view = DetectionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初期化
        setBeaconResult(nil)

        // ビーコン用UUID設定
        self.proximityUUID = UUID(uuidString: Const.PROXIMITY_UUID)!
        self.beaconRegion = CLBeaconRegion(proximityUUID: self.proximityUUID!, identifier: "一意キー")

        self.manager = CLLocationManager()
        self.manager.delegate = self
        
        let view = self.view as! DetectionView
        
        // ボタン設定
        view.sendBtn.addTarget(self, action: #selector(self.sendBtnTouchUpInside(_:)), for: .touchUpInside)
        view.retryBtn.addTarget(self, action: #selector(self.retryBtnTouchUpInside(_:)), for: .touchUpInside)
        view.helpBtn.addTarget(self, action: #selector(self.helpBtnTouchUpInside(_:)), for: .touchUpInside)
        view.stopBtn.addTarget(self, action: #selector(self.stopBtnTouchUpInside(_:)), for: .touchUpInside)
        
        view.statusLabel.text = self.getAuthorizationStatusString()

        // 検知開始
        self.manager.startMonitoring(for: self.beaconRegion!)
    }
    
    private func getAuthorizationStatusString() -> (String) {
        
        // 位置情報サービス認証状態
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            print("使用許可")
            return "使用許可"
        case .authorizedWhenInUse:
            print("iBeacon距離観測可能")
            return "測定可能"
        case .denied:
            print("使用拒否")
            return "使用拒否"
        case .notDetermined:
            print("許可未済")
            // 認証要求
            self.manager.requestAlwaysAuthorization()
            return "許可未済"
        default:
            print("機能制限")
            return  "機能制限"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        // 縦画面固定
        return UIInterfaceOrientationMask.portrait
    }

    // MARK: - iBeacon
    
    // 領域モニタリング開始
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("モニタリング開始")
        let view = self.view as! DetectionView
        view.statusLabel.text = "モニタリング開始"
        manager.requestState(for: region)
    }
    
    // 領域モニタリング停止
    func locationManager(_ manager: CLLocationManager, didStopMonitoringForRegion region: CLRegion) {
        print("モニタリング停止")
        let view = self.view as! DetectionView
        view.statusLabel.text = "測定停止中"
    }
    
    // モニタリング結果判定
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {

        // リージョン判定
        switch (state) {
        case .inside:
            print("距離測定開始")
            let view = self.view as! DetectionView
            view.statusLabel.text = "距離測定開始"
            manager.startRangingBeacons(in: self.beaconRegion!)
        case .outside:
            print("距離測定対象外距離")
            let view = self.view as! DetectionView
            view.statusLabel.text = "距離測定対象外距離"
        default:
            print("不明")
            let view = self.view as! DetectionView
            view.statusLabel.text = "不明"
        }
    }
    
    // リージョン監視失敗
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("距離測定監視失敗")


        if ((region?.isKind(of: CLBeaconRegion.self)) != nil) {
            print("iBeacon測定判定失敗")
            let view = self.view as! DetectionView
            view.statusLabel.text = "測定失敗"
        }
    }

    // 通信失敗
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("エラーコード:" + String(error._code))
        let view = self.view as! DetectionView
        view.statusLabel.text = "通信失敗 エラーコード:" + String(error._code)
    }
    
    // 領域内判定
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("距離内")
        let view = self.view as! DetectionView
        view.statusLabel.text = "測定距離内"
    }
    
    // 領域外判定
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("距離外")
        let view = self.view as! DetectionView
        view.statusLabel.text = "測定距離外"
    }
    
    // ビーコン確保
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
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

            let view = self.view as! DetectionView
            
            switch (beacon.proximity) {
            case .unknown:
                print("見つかりません")
                view.statusLabel.text = "みつかりません"
                // 結果初期化
                setBeaconResult(nil)
            case .immediate:
                print("近くにあります: 50cm以内？")
                view.statusLabel.text = "およそ50cm以内"
            case .near:
                print("わりと近くにあります: 50cm~6m?")
                view.statusLabel.text = "およそ50cm~6mの範囲内"
            default:
                print("かなり遠いです: 6m~20m?")
                view.statusLabel.text = "およそ6m~20mの範囲内"
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
        }
    }

    // MARK: - Action
    
    // 送信ボタン
    func sendBtnTouchUpInside(_ sender: UIButton) {
        print("送信ボタン押下")
        // ???: 現在地不可の場合、そもそもBeacon自体取得できないんだし、送信ボタン自体をdisableにしたほうがいいかな？
        // ???: 今のところ送信前にチェックしている
        sendBeaconDetectionData()
    }
    
    // Helpボタン
    func helpBtnTouchUpInside(_ sender: UIButton) {
        print("help")
        let helpViewController = HelpViewController()
        helpViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(helpViewController, animated: true, completion: nil)
    }
    
    // 再検知ボタン
    func retryBtnTouchUpInside(_ sender: UIButton) {
        print("再検知")
        if(!viewModel.isMonitoringCapable()){
            // 実施可能ではない
            return
        }
        self.manager.startRangingBeacons(in: self.beaconRegion!)
    }

    // 検知停止ボタン
    func stopBtnTouchUpInside(_ sender: UIButton) {
        print("停止")
        self.manager.stopRangingBeacons(in: self.beaconRegion!)
    }

    // MARK: - Tools

    // 検知内容を送信する
    func sendBeaconDetectionData() {
        print("サーバ送信")
        
        // 送信前に検知を停止
        self.manager.stopMonitoring(for: self.beaconRegion!)
        
        // ローディング
        SVProgressHUD.show(withStatus: "通信中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        // 検出データ送信
        let postUrl = Const.DESTINATION_BASE_URL + Const.DESTINATION_API_URL
        
        let manager = AFHTTPSessionManager()
        
        let view = self.view as! DetectionView
        
        var param:Dictionary<String, String> = ["":""]
        param["proximityUUID"] = view.proximityUUIDLabel.text!
        param["major"] = view.majorLabel.text!
        param["minor"] = view.minorLabel.text!
        param["accuracy"] = view.accuracyLabel.text!
        param["rssi"] = view.rssiLabel.text!
        
        viewModel.setLocation(param: &param)
        
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

    // 通知内容を設定する(nil == 初期化)
    func setBeaconResult(_ beacon: CLBeacon?) {
        
        let view = self.view as! DetectionView
        
        // 表示設定
        if beacon == nil {
            view.proximityUUIDLabel.text = ""
            view.majorLabel.text = ""
            view.minorLabel.text = ""
            view.accuracyLabel.text = ""
            view.rssiLabel.text = ""
        } else {
            view.proximityUUIDLabel.text = beacon!.proximityUUID.uuidString
            view.majorLabel.text = "\(beacon!.major)"
            view.minorLabel.text = "\(beacon!.minor)"
            view.accuracyLabel.text = "\(beacon!.accuracy)"
            view.rssiLabel.text = "\(beacon!.rssi)"
        }
    }
}

extension DetectionViewController : CLLocationManagerDelegate {
    
}
