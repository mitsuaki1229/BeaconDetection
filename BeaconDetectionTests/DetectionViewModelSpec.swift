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
            context("未設定の場合デフォルトのUUID Stringを設定する", {
                
                let tmpUuidString = UserDefaults.standard.string(forKey: Const.kProximityUUIDStringUserDefaultKey)
                
                beforeEach {
                    DetectionViewModel().updateProximityUUIDToDefault()
                }
                
                afterEach {
                    UserDefaults.standard.set(tmpUuidString, forKey: Const.kProximityUUIDStringUserDefaultKey)
                }
                
                it("デフォルトのUUID Stringが設定されていること", closure: {
                    // FIXME: 下記テストが通るようにアプリ修正を実施する
                    expect(UserDefaults.standard.string(forKey: Const.kProximityUUIDStringUserDefaultKey)) == Const.kDefaultProximityUUIDString
                })
            })
        }
        describe("updateProximityUUID") {
            context("UUID Stringを更新する", {
                
                let tmpUuidString = UserDefaults.standard.string(forKey: Const.kProximityUUIDStringUserDefaultKey)
                let assertUuidString = NSUUID().uuidString
                
                beforeEach {
                    DetectionViewModel().updateProximityUUID(uuidText: assertUuidString)
                }
                
                afterEach {
                    UserDefaults.standard.set(tmpUuidString, forKey: Const.kProximityUUIDStringUserDefaultKey)
                }
                
                it("UUID Stringが更新されていること", closure: {
                    expect(UserDefaults.standard.string(forKey: Const.kProximityUUIDStringUserDefaultKey)) == assertUuidString
                })
            })
        }
        describe("updateInputMajor") {
            context("majorを更新する", {
                
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
                
                it("majorが更新されていること", closure: {
                    XCTAssertEqual(mockObserver.events, [
                        next(100, ""),
                        next(200, assertText)
                        ])
                })
            })
        }
        describe("updateInputMinor") {
            context("minorを更新する", {
                
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
                
                it("minorが更新されていること", closure: {
                    XCTAssertEqual(mockObserver.events, [
                        next(100, ""),
                        next(200, assertText)
                        ])
                })
            })
        }
        describe("clearSections") {
            context("テーブルの一覧を初期化する", {
                
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
                
                it("一覧が初期化されていること", closure: {
                    
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
                
                it("Beaconの検索範囲が変更されていること", closure: {
                    
                    var assertEvents = [next(100, #imageLiteral(resourceName: "RangingButtonIconStart"))]
                    
                    if (mockStatusObserver.events.first(where: { return $0.value.element != "" })?.value.element?.isEmpty)! {
                        assertEvents = [
                            next(100, #imageLiteral(resourceName: "RangingButtonIconStart")),
                            next(200, #imageLiteral(resourceName: "RangingButtonIconPause"))
                        ]
                    }
                    
                    XCTAssertEqual(mockObserver.events, assertEvents)
                })
            })
        }
        describe("reSettingBeaconManager") {
            context("Beaconマネージャーを再設定する", {
                
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
                
                it("Beaconマネージャーが再設定されていること", closure: {
                    
                    var assertEvents = [next(100, #imageLiteral(resourceName: "RangingButtonIconStart"))]
                    
                    if (mockStatusObserver.events.first(where: { return $0.value.element != "" })?.value.element?.isEmpty)! {
                        assertEvents = [
                            next(100, #imageLiteral(resourceName: "RangingButtonIconStart")),
                            next(200, #imageLiteral(resourceName: "RangingButtonIconPause"))
                        ]
                    }
                    
                    XCTAssertEqual(mockObserver.events, assertEvents)
                })
            })
        }
    }
}
