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

        describe("シグナルの内容を更新する") {
            context("", {
                let scheduler = TestScheduler(initialClock: 0)
                
                let results = scheduler.createObserver(SimulatorViewModelState.self)
                
                let viewModel = SimulatorViewModel()
                viewModel.status.subscribe(results).disposed(by: DisposeBag())

                scheduler.scheduleAt(100) {  }
                scheduler.scheduleAt(200) { viewModel.updateStatusSignal() }
                scheduler.start()
                
//                expect(results.events).to(equal(expectedEvents))
            })
        }
        
        describe("ビーコンの情報を再生成する") {
            context("", {
                
            })
        }
        
        describe("ランダムの数値を返却する") {
            context("", {
                
            })
        }
    }
}
