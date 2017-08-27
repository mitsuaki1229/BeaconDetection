//
//  BeaconDetectionTests.swift
//  BeaconDetectionTests
//
//  Created by 伊原光明 on 2015/11/06.
//  Copyright © 2015年 Mitsuaki Ihara. All rights reserved.
//

import XCTest
import Quick
import Nimble
import OHHTTPStubs
import AFNetworking

@testable import BeaconDetection

class BeaconDetectionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testApi() {
        
        installStub(isOn: true)
        
        let postUrl = Const.DESTINATION_BASE_URL + Const.DESTINATION_API_ENDPOINT
        
        let manager = AFHTTPSessionManager()
        
        let param:Dictionary<String, String> = ["test":"testVar"]
        
        var keepAlive = true
        
        manager .post(
            postUrl,
            parameters: param,
            progress: nil,
            success: { (operation, responseObject) in
                
                print("通信成功")
                
                let json = responseObject as! Dictionary<String, Any>
                
                let id: Int = json["id"] as! Int
                let message: String = json["message"] as! String
                let user: Dictionary<String, Any> = json["user"] as! Dictionary<String, Any>
                let userId: Int = user["userId"] as! Int
                let name: String = user["name"] as! String
                let fileName: String = user["fileName"] as! String
                
                print(id)
                print(message)
                print(userId)
                print(name)
                print(fileName)
                
                keepAlive = false
        },
            failure: { (operation, error) in
                print("通信失敗:" + String(describing: error))
                keepAlive = false
        })
        
        let runLoop = RunLoop.current
        while keepAlive &&
            runLoop.run(mode: .defaultRunLoopMode, before: Date(timeIntervalSinceNow: 0.1)) {
                // 処理継続
        }
        
        installStub(isOn: false)
        
        XCTAssert(true)
    }
    
    var jsonStub: OHHTTPStubsDescriptor?
    private func installStub(isOn: Bool) {
        
        guard isOn else {
            OHHTTPStubs.removeStub(jsonStub!)
            return
        }
        
        let endpoint = Const.DESTINATION_API_ENDPOINT
        
        jsonStub = OHHTTPStubs.stubRequests(
            passingTest: { (request) -> Bool in
                
                return request.url?.path == endpoint
        }, withStubResponse: { (request) -> OHHTTPStubsResponse in
            
            let stubPath = OHPathForFile("stub.json", type(of: self))
            return OHHTTPStubsResponse(fileAtPath: stubPath!, statusCode: 200, headers: ["Content-Type": "application/json"])
        })
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
