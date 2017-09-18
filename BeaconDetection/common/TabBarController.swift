//
//  TabBarController.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2017/09/18.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        setUpViewControllers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setUpViewControllers() {
        
        var viewControllers: [UIViewController] = []
        
        let detectionViewController = DetectionViewController()
        detectionViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .mostRecent, tag: 1)
        
        let detectionNavigationController = UINavigationController(rootViewController: detectionViewController)
        viewControllers.append(detectionNavigationController)
        
        let simulatorViewController = SimulatorViewController()
        simulatorViewController.tabBarItem  = UITabBarItem(tabBarSystemItem: .mostRecent, tag: 2)
        let simulatorViewNavigationController = UINavigationController(rootViewController: simulatorViewController)
        viewControllers.append(simulatorViewNavigationController)
        
        let settingViewController = SettingViewController()
        settingViewController.tabBarItem  = UITabBarItem(tabBarSystemItem: .mostRecent, tag: 3)
        let settingNavigationController = UINavigationController(rootViewController: settingViewController)
        viewControllers.append(settingNavigationController)
        
        self.viewControllers = viewControllers
    }
}
