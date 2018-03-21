//
//  DummyUITests.swift
//  BeaconDetectionUITests
//
//  Created by Mitsuaki Ihara on 2018/03/21.
//  Copyright © 2018年 Mitsuaki Ihara. All rights reserved.
//

import XCTest

class DummyUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    func testExample() {
    }
}
