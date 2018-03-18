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
        describe("dataSource") {
            context("データソースを更新する", {
                it("データソースが更新されていること", closure: {
                    // TODO: Write a test. mitsuaki1229
                })
            })
        }
        describe("clearCheckedTips") {
            context("使い方ヒントの読込状態を初期化する", {
                
                UserDefaults().set(2, forKey: Const.kCheckedTipsUserDefaultKey)
                
                let viewModel = SettingViewModel()
                viewModel.clearCheckedTips()
                
                it("読込状態が初期化されていること", closure: {
                    expect(UserDefaults().integer(forKey: Const.kCheckedTipsUserDefaultKey)) == 0
                })
            })
        }
    }
}
