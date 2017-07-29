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
        self.view = HelpView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
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
        self.dismiss(animated: true, completion: nil)
    }
}
