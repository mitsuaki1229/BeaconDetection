//
//  SimulatorViewModelSpec.swift
//  BeaconDetectionTests
//
//  Created by Mitsuaki Ihara on 2017/09/30.
//  Copyright © 2017年 Mitsuaki Ihara. All rights reserved.
//

import Nimble
import Quick
import RxSwift
import RxTest

@testable import BeaconDetection

class SimulatorViewModelSpec: QuickSpec {
    
    override func spec() {
        
        describe("updateStatusSignal") {
            context("statusを更新する", {
                it("statusが更新されること", closure: {
                    // TODO: Write a test. mitsuaki1229
                })
            })
        }
        describe("regenerateBeacon") {
            context("ビーコンの情報を再生成する", {
                it("statusが利用中になること", closure: {
                    // TODO: Write a test. mitsuaki1229
                })
            })
        }
    }
}
