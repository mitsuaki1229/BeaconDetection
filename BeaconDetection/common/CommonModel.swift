//
//  CommonModel.swift
//  BeaconDetection
//
//  Created by Mitsuaki Ihara on 2018/03/22.
//  Copyright © 2018年 Mitsuaki Ihara. All rights reserved.
//

import Foundation

class CommonModel: NSObject {
    
    var nextTips: (() -> Int) = {
        return UserDefaults().integer(forKey: Const.kCheckedTipsUserDefaultKey) + 1
    }
}
