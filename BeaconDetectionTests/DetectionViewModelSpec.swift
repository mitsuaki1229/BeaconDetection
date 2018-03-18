//
//  DetectionViewModelSpec.swift
//  BeaconDetectionTests
//
//  Created by Mitsuaki Ihara on 2018/03/18.
//  Copyright © 2018年 Mitsuaki Ihara. All rights reserved.
//

import Nimble
import Quick

@testable import BeaconDetection

class DetectionViewModelSpec: QuickSpec {
    
    override func spec() {
        describe("updateProximityUUIDToDefault") {
            context("デフォルトのUUID Stringを設定する", {
                it("デフォルトのUUID Stringが設定されていること", closure: {
                    // TODO: Write a test. mitsuaki1229
                })
            })
        }
        describe("updateProximityUUID") {
            context("UUID Stringを更新する", {
                it("UUID Stringが更新されていること", closure: {
                    // TODO: Write a test. mitsuaki1229
                })
            })
        }
        describe("updateInputMajor") {
            context("majorを更新する", {
                it("majorが更新されていること", closure: {
                    // TODO: Write a test. mitsuaki1229
                })
            })
        }
        describe("updateInputMinor") {
            context("minorを更新する", {
                it("minorが更新されていること", closure: {
                    // TODO: Write a test. mitsuaki1229
                })
            })
        }
        describe("clearSections") {
            context("テーブルの一覧を初期化する", {
                it("一覧が初期化されていること", closure: {
                    // TODO: Write a test. mitsuaki1229
                })
            })
        }
        describe("changeRanging") {
            context("Beaconの検索範囲を変更する", {
                it("Beaconの検索範囲が変更されていること", closure: {
                    // TODO: Write a test. mitsuaki1229
                })
            })
        }
        describe("reSettingBeaconManager") {
            context("Beaconマネージャーを再設定する", {
                it("Beaconマネージャーが再設定されていること", closure: {
                    // TODO: Write a test. mitsuaki1229
                })
            })
        }
    }
}
