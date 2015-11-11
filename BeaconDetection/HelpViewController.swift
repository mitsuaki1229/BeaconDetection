//
//  HelpViewController.swift
//  BeaconDetection
//
//  Created by 伊原光明 on 2015/11/11.
//  Copyright © 2015年 Mitsuaki Ihara. All rights reserved.
//

class HelpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.alpha = 0.5
        self.view.backgroundColor = UIColor.whiteColor()
        self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}