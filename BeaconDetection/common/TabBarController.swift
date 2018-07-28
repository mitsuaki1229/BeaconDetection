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
        
        viewControllers.append({ () -> UINavigationController in
            let vc = DetectionViewController()
            vc.tabBarItem = UITabBarItem(title: "Detection", image: #imageLiteral(resourceName: "DetectionItemIcon"), tag: 1)
            return UINavigationController(rootViewController: vc)
            }())
        
        viewControllers.append({ () -> UINavigationController in
            let vc = SimulatorViewController()
            vc.tabBarItem = UITabBarItem(title: "Simulator", image: #imageLiteral(resourceName: "SimulatorItemIcon"), tag: 2)
            return UINavigationController(rootViewController: vc)
            }())
        
        viewControllers.append({ () -> UINavigationController in
            let vc = SettingViewController()
            vc.tabBarItem = UITabBarItem(title: "Setting", image: #imageLiteral(resourceName: "SettingItemIcon"), tag: 3)
            return UINavigationController(rootViewController: vc)
            }())
        
        self.viewControllers = viewControllers
    }
}
