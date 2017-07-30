//
//  DetectionViewModel.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/07/29.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import Foundation
import CoreLocation
import INTULocationManager

class DetectionViewModel: NSObject {
    
    override init() {
        super.init()
    }
    
    /// ビーコンが使用できるか確認
    func isMonitoringCapable() -> Bool {
        if (!CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self)) {
            return false;
        }
        return true;
    }
    
    /// 現在地情報を送信情報にセットする
    func setLocation(param: inout Dictionary<String, String>) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            
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
                                        print("success")
                                    case .timedOut:
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
            
        } else {
            print("現在地使用不可")
        }
    }
    
    /// 位置情報サービス認証状態を返す
    func getAuthorizationStatusString() -> (String) {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            return "使用許可"
        case .authorizedWhenInUse:
            return "測定可能"
        case .denied:
            return "使用拒否"
        case .notDetermined:
            return "許可未済"
        default:
            return "機能制限"
        }
    }

}
