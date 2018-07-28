//
//  SettingViewModelSpec.swift
//  BeaconDetectionTests
//
//  Created by Mitsuaki Ihara on 2018/03/18.
//  Copyright © 2018年 Mitsuaki Ihara. All rights reserved.
//

import Nimble
import Quick

@testable import BeaconDetection

class SettingViewModelSpec: QuickSpec {
    
    override func spec() {
        describe("clearCheckedTips") {
            context("使い方ヒントの読込状態を初期化する", {
                
                var tmpUuid: String?
                beforeEach {
                    tmpUuid = UserDefaults.standard.string(forKey: Const.kCheckedTipsUserDefaultKey)
                }
                
                afterEach {
                    UserDefaults.standard.set(tmpUuid, forKey: tmpUuid!)
                }
                
                it("読込状態が初期化されていること", closure: {
                    
                    UserDefaults().set(2, forKey: Const.kCheckedTipsUserDefaultKey)
                    
                    SettingViewModel().clearCheckedTips()
                    
                    expect(UserDefaults().integer(forKey: Const.kCheckedTipsUserDefaultKey)) == 0
                })
            })
        }
    }
}
