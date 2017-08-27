//
//  HelpViewController.swift
//  BeaconDetection
//
//  Created by 伊原光明 on 2015/11/11.
//  Copyright © 2015年 Mitsuaki Ihara. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    override func loadView() {
        view = HelpView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
}
