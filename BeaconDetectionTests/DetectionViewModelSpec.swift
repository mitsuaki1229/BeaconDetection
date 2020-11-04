//
//  DetectionViewModelSpec.swift
//  BeaconDetectionTests
//
//  Created by Mitsuaki Ihara on 2018/03/18.
//  Copyright © 2018年 Mitsuaki Ihara. All rights reserved.
//

import Nimble
import Quick
import RxSwift
import RxTest

@testable import BeaconDetection

class DetectionViewModelSpec: QuickSpec {
    
    override func spec() {
        describe("updateProximityUUIDToDefault") {
            context("inputのUUIDにUserDefaultのUUID Stringを設定する", {
                
                var tmpUuid: String?
                
                beforeEach {
                    tmpUuid = UserDefaults.standard.string(forKey: Const.kProximityUUIDStringUserDefaultKey)
                }
                
                afterEach {
                    UserDefaults.standard.set(tmpUuid, forKey: Const.kProximityUUIDStringUserDefaultKey)
                }
                
                it("UserDefaultに保持しているUUID Stringがinputに設定されていること", closure: {
                    
                    let assetUUIDString = "D864C04A-46DC-46CA-AD26-8734FA780336"
                    UserDefaults.standard.set(assetUUIDString, forKey: Const.kProximityUUIDStringUserDefaultKey)
                    
                    var mockObserver: TestableObserver<String>?
                    
                    let scheduler = TestScheduler(initialClock: 0)
                    mockObserver = scheduler.createObserver(String.self)
                    let viewModel = DetectionViewModel()
                    let disposeBag = DisposeBag()
                    
                    scheduler.scheduleAt(100, action: {
                        viewModel.inputProximityUUID.subscribe(mockObserver!).disposed(by: disposeBag)
                    })
                    
                    scheduler.scheduleAt(200, action: {
                        viewModel.updateProximityUUIDToUserDefault()
                    })
                    
                    scheduler.start()
                    
                    XCTAssertEqual(mockObserver!.events, [
                        Recorded.next(100, assetUUIDString),
                        Recorded.next(200, assetUUIDString)
                        ])
                })
            })
        }
        describe("updateProximityUUID") {
            context("UUID Stringを更新する", {
                
                var tmpUuidString: String?
                
                beforeEach {
                    tmpUuidString = UserDefaults.standard.string(forKey: Const.kProximityUUIDStringUserDefaultKey)

                }
                
                afterEach {
                    UserDefaults.standard.set(tmpUuidString, forKey: Const.kProximityUUIDStringUserDefaultKey)
                }
                
                it("UUID Stringが更新されていること", closure: {
                    
                    let assertUuidString = NSUUID().uuidString
                    DetectionViewModel().updateProximityUUID(uuidText: assertUuidString)
                    expect(UserDefaults.standard.string(forKey: Const.kProximityUUIDStringUserDefaultKey)) == assertUuidString
                })
            })
        }
        describe("updateInputMajor") {
            context("majorを更新する", {
                it("majorが更新されていること", closure: {
                    
                    let scheduler = TestScheduler(initialClock: 0)
                    let mockObserver = scheduler.createObserver(String.self)
                    let viewModel = DetectionViewModel()
                    let disposeBag = DisposeBag()
                    
                    scheduler.scheduleAt(100, action: {
                        viewModel.inputMajor.subscribe(mockObserver).disposed(by: disposeBag)
                    })
                    
                    let assertText = "1"
                    
                    scheduler.scheduleAt(200, action: {
                        viewModel.updateInputMajor(text: assertText)
                    })
                    
                    scheduler.start()
                    
                    XCTAssertEqual(mockObserver.events, [
                        Recorded.next(100, ""),
                        Recorded.next(200, assertText)
                        ])
                })
            })
        }
        describe("updateInputMinor") {
            context("minorを更新する", {
                it("minorが更新されていること", closure: {
                    
                    let scheduler = TestScheduler(initialClock: 0)
                    let mockObserver = scheduler.createObserver(String.self)
                    let viewModel = DetectionViewModel()
                    let disposeBag = DisposeBag()
                    
                    scheduler.scheduleAt(100, action: {
                        viewModel.inputMinor.subscribe(mockObserver).disposed(by: disposeBag)
                    })
                    
                    let assertText = "2"
                    
                    scheduler.scheduleAt(200, action: {
                        viewModel.updateInputMinor(text: assertText)
                    })
                    
                    scheduler.start()
                    
                    XCTAssertEqual(mockObserver.events, [
                        Recorded.next(100, ""),
                        Recorded.next(200, assertText)
                        ])
                })
            })
        }
        describe("clearSections") {
            context("テーブルの一覧を初期化する", {
                it("一覧が初期化されていること", closure: {
                    
                    let scheduler = TestScheduler(initialClock: 0)
                    let mockObserver = scheduler.createObserver([SectionDetectionInfoListData].self)
                    let viewModel = DetectionViewModel()
                    let disposeBag = DisposeBag()
                    
                    scheduler.scheduleAt(100, action: {
                        viewModel.sections.subscribe(mockObserver).disposed(by: disposeBag)
                    })
                    
                    scheduler.scheduleAt(200, action: {
                        viewModel.clearSections()
                    })
                    
                    scheduler.start()
                    
                    var assertSections = [[SectionDetectionInfoListData]]()
                    
                    mockObserver.events.forEach({
                        assertSections.append($0.value.element!)
                    })
                    
                    XCTAssertEqual(assertSections[0], [SectionDetectionInfoListData(header: "Info", items: [])])
                    XCTAssertEqual(assertSections[1], [SectionDetectionInfoListData(header: "Info", items: [])])
                })
            })
        }
        describe("changeRanging") {
            context("Beaconの検索範囲を変更する", {
                it("Beaconの検索範囲が変更されていること", closure: {
                    
                    let scheduler = TestScheduler(initialClock: 0)
                    let viewModel = DetectionViewModel()
                    let mockObserver = scheduler.createObserver(UIImage.self)
                    let mockStatusObserver = scheduler.createObserver(String.self)
                    let disposeBag = DisposeBag()
                    
                    scheduler.scheduleAt(100, action: {
                        viewModel.rangingButtonIcon.subscribe(mockObserver).disposed(by: disposeBag)
                        viewModel.status.subscribe(mockStatusObserver).disposed(by: disposeBag)
                    })
                    
                    scheduler.scheduleAt(200, action: {
                        viewModel.changeRanging()
                    })
                    
                    scheduler.start()
                    
                    var assertEvents = [Recorded.next(100, #imageLiteral(resourceName: "RangingButtonIconStart"))]
                    
                    if (mockStatusObserver.events.first(where: { return $0.value.element != "" })?.value.element?.isEmpty)! {
                        assertEvents = [
                            Recorded.next(100, #imageLiteral(resourceName: "RangingButtonIconStart")),
                            Recorded.next(200, #imageLiteral(resourceName: "RangingButtonIconPause"))
                        ]
                    }
                    
                    XCTAssertEqual(mockObserver.events, assertEvents)
                })
            })
        }
        describe("reSettingBeaconManager") {
            context("Beaconマネージャーを再設定する", {
                it("Beaconマネージャーが再設定されていること", closure: {
                    
                    let scheduler = TestScheduler(initialClock: 0)
                    let viewModel = DetectionViewModel()
                    let mockObserver = scheduler.createObserver(UIImage.self)
                    let mockStatusObserver = scheduler.createObserver(String.self)
                    let disposeBag = DisposeBag()
                    
                    scheduler.scheduleAt(100, action: {
                        viewModel.rangingButtonIcon.subscribe(mockObserver).disposed(by: disposeBag)
                        viewModel.status.subscribe(mockStatusObserver).disposed(by: disposeBag)
                    })
                    
                    scheduler.scheduleAt(200, action: {
                        viewModel.changeRanging()
                    })
                    
                    scheduler.start()
                    
                    var assertEvents = [Recorded.next(100, #imageLiteral(resourceName: "RangingButtonIconStart"))]
                    
                    if (mockStatusObserver.events.first(where: { return $0.value.element != "" })?.value.element?.isEmpty)! {
                        assertEvents = [
                            Recorded.next(100, #imageLiteral(resourceName: "RangingButtonIconStart")),
                            Recorded.next(200, #imageLiteral(resourceName: "RangingButtonIconPause"))
                        ]
                    }
                    
                    XCTAssertEqual(mockObserver.events, assertEvents)
                })
            })
        }
    }
}
