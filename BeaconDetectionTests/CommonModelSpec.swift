//
//  CommonModelSpec.swift
//  BeaconDetectionTests
//
//  Created by Mitsuaki Ihara on 2018/03/22.
//  Copyright © 2018年 Mitsuaki Ihara. All rights reserved.
//

import Nimble
import Quick

@testable import BeaconDetection

class CommonModelSpec: QuickSpec {
    
    override func spec() {
        describe("nextTips") {
            context("次に取得するポップチップの番号を取得する", {
                
                var tmpCheckedTips = 0
                
                beforeEach {
                    tmpCheckedTips = UserDefaults().integer(forKey: Const.kCheckedTipsUserDefaultKey)
                    UserDefaults().set(1, forKey: Const.kCheckedTipsUserDefaultKey)
                }
                
                afterEach {
                    UserDefaults().set(tmpCheckedTips, forKey: Const.kCheckedTipsUserDefaultKey)
                }
                
                it("番号が取得出来ること", closure: {
                    expect(CommonModel().nextTips()) == 2
                })
            })
        }
    }
}
