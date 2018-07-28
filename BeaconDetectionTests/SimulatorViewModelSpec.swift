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
                    
                    let scheduler = TestScheduler(initialClock: 0)
                    let viewModel = SimulatorViewModel()
                    let mockObserver = scheduler.createObserver(SimulatorViewModelState.self)
                    let disposeBag = DisposeBag()
                    
                    scheduler.scheduleAt(100, action: {
                        viewModel.status.subscribe(mockObserver).disposed(by: disposeBag)
                    })
                    
                    scheduler.scheduleAt(200, action: {
                        viewModel.updateStatusSignal()
                    })
                    
                    scheduler.start()
                    
                    XCTAssertEqual(mockObserver.events, [
                        next(100, .other),
                        next(200, .other)
                        ])
                })
            })
        }
        describe("regenerateBeacon") {
            context("ビーコンの情報を再生成する", {
                
                var tmpUuid: String?
                beforeEach {
                    tmpUuid = UserDefaults.standard.string(forKey: Const.kProximityUUIDStringUserDefaultKey)
                }
                
                afterEach {
                    UserDefaults.standard.set(tmpUuid, forKey: Const.kProximityUUIDStringUserDefaultKey)
                }
                
                it("statusが利用中になること", closure: {
                    
                    UserDefaults.standard.set(Const.kDefaultProximityUUIDString, forKey: Const.kProximityUUIDStringUserDefaultKey)
                    
                    let scheduler = TestScheduler(initialClock: 0)
                    let mockObserver = scheduler.createObserver(SimulatorViewModelState.self)
                    
                    let viewModel = SimulatorViewModel()
                    let disposeBag = DisposeBag()
                    
                    scheduler.scheduleAt(100, action: {
                        viewModel.status.subscribe(mockObserver).disposed(by: disposeBag)
                    })
                    
                    scheduler.scheduleAt(200, action: {
                        viewModel.regenerateBeacon()
                    })
                    
                    scheduler.start()
                    
                    XCTAssertEqual(mockObserver.events, [
                        next(100, .other),
                        next(200, .normal)
                        ])
                })
            })
        }
    }
}
