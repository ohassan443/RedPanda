//
//  InternetConnectivityCheckerTests.swift
//  ZabatneeTests
//
//  /Users/omarhassanmohamed/Desktop/cocoapods/ImageCollectionLoader/UnitTests/InternetConnectivityCheckerMockTests.swiftCreated by Omar Hassan  on 2/3/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest

@testable import ImageCollectionLoader

class InternetConnectivityCheckerTests: XCTestCase {

    //this test bings google and will fail if no internet is avaliable on the machine running this test
    func testFunctionality() {
        
        let successExp = expectation(description: "pingedServer and retuned success")
        let failedExp = expectation(description: "pingedServer and returned fail")
        
        
        var locaclServerChangingResponse  = LocallServer.LocalServerCallBack(statusCode: .s500, headers: [], body: nil)
        let response : LocallServer.wrappedResponse = {
     	params,callBack in
            callBack(locaclServerChangingResponse)
        }
    	 let server = LocallServer.getInstance(response: response)
        
        let internetChecker = InternetConnectivityCheckerBuilder().concrete(url: UITestsConstants.baseUrl)
        locaclServerChangingResponse = LocallServer.LocalServerCallBack(statusCode: .s200, headers: [], body: Data())
        
        internetChecker.check(completionHandler: {
            result in
            XCTAssertTrue(result)
            successExp.fulfill()
        })
        wait(for: [successExp], timeout: 10)
        
        locaclServerChangingResponse = LocallServer.LocalServerCallBack(statusCode: .s500, headers: [], body: nil)
        internetChecker.check(completionHandler: {
            result in
            XCTAssertFalse(result)
            failedExp.fulfill()
        })
        
        wait(for: [failedExp], timeout: 10)
        
        addTeardownBlock {
            server.stop()
        }
    }
}
