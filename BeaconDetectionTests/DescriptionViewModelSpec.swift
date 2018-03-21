//
//  DescriptionViewModelSpec.swift
//  BeaconDetectionTests
//
//  Created by Mitsuaki Ihara on 2018/03/18.
//  Copyright © 2018年 Mitsuaki Ihara. All rights reserved.
//

import Nimble
import Quick

@testable import BeaconDetection

class DescriptionViewModelSpec: QuickSpec {
    
    override func spec() {
        describe("getHtml") {
            context("type:readmeにてHTML文字列を取得する", {
                it("対応したHTML文字列が取得出来ること", closure: {
                    expect(DescriptionViewModel(type: .readme).getHtml()) == "<h1>BeaconDetection</h1>\n<p>Beacon experience.</p>\n<h2>Requirement</h2>\n<ul>\n<li>Swift 4</li>\n<li><a href=\"https://developer.apple.com/download/\">Xcode 9.2</a></li>\n<li><a href=\"https://github.com/Carthage/Carthage\">Carthage 0.28.0</a></li>\n<li><a href=\"https://github.com/realm/SwiftLint\">Swiftlint 0.25.0</a></li>\n</ul>\n<h2>Install</h2>\n<p><code>\n$ cd BeaconDetection/\n$ carthage update --platform iOS\n</code></p>\n<h2>Usage</h2>\n<ul>\n<li>DetectionView</li>\n<li>Search and display Beacons info.</li>\n<li>Simulator</li>\n<li>Instration App is become Beacon.</li>\n</ul>\n<h2>Licence</h2>\n<p>This software is released under the MIT License, see LICENSE.md.</p>\n<h2>Author</h2>\n<p><a href=\"https://github.com/mitsuaki1229\">mitsuaki1229</a></p>\n"
                })
            })
            context("type:licenseにてHTML文字列を取得する", {
                it("対応したHTML文字列が取得出来ること", closure: {
                    expect(DescriptionViewModel(type: .license).getHtml()) == "<p>Copyright (c) 2015 Mitsuaki Ihara</p>\n<p>Permission is hereby granted, free of charge, to any person obtaining a copy\nof this software and associated documentation files (the \"Software\"), to deal\nin the Software without restriction, including without limitation the rights\nto use, copy, modify, merge, publish, distribute, sublicense, and/or sell\ncopies of the Software, and to permit persons to whom the Software is\nfurnished to do so, subject to the following conditions:</p>\n<p>The above copyright notice and this permission notice shall be included in\nall copies or substantial portions of the Software.</p>\n<p>THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\nIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\nFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE\nAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\nLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\nOUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\nTHE SOFTWARE.</p>\n"
                })
            })
            context("type:noneにてHTML文字列を取得する", {
                it("対応したHTML文字列が取得出来ないこと", closure: {
                    expect(DescriptionViewModel(type: .none).getHtml()) == ""
                })
            })
        }
        describe("getTitle") {
            context("type:readmeにてタイトルを取得する", {
                it("対応したタイトルが取得出来ること", closure: {
                    expect(DescriptionViewModel(type: .readme).getTitle()) == "README"
                })
            })
            context("type:licenseにてタイトルを取得する", {
                it("対応したタイトルが取得出来ること", closure: {
                    expect(DescriptionViewModel(type: .license).getTitle()) == "LICENSE"
                })
            })
            context("type:noneにてタイトルを取得する", {
                it("対応したタイトルが取得出来ること", closure: {
                    expect(DescriptionViewModel(type: .none).getTitle()) == ""
                })
            })
        }
    }
}
