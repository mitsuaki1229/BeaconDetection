//
//  AppDelegate.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2015/11/06.
//  Copyright © 2015年 Mitsuaki Ihara. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        setProximityUUIDDefault()
        
        let viewController = TabBarController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    private func setProximityUUIDDefault() {
        guard UserDefaults.standard.string(forKey: "kProximityUUIDString") == nil else { return }
        UserDefaults.standard.set(Const.kDefaultProximityUUIDString, forKey: "kProximityUUIDString")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
}
