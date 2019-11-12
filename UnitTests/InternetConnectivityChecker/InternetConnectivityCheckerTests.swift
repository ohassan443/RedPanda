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
        
        let expSuccess = expectation(description: "pinged Server and retuned success")
        let expFail = expectation(description: "pinged Server and returned fail")
        
        /// setup local server and internet checker concrete instance
        var locaclServerChangingResponse  = LocalServer.LocalServerCallBack(statusCode: .s500, headers: [], body: nil)
        let response : LocalServer.wrappedResponse = {
     	params,callBack in
            callBack(locaclServerChangingResponse)
        }
        let server = LocalServer.getInstance(response: response)
        
        let internetChecker = InternetConnectivityCheckerBuilder().concrete(url: UITestsConstants.baseUrl)
        locaclServerChangingResponse = LocalServer.LocalServerCallBack(statusCode: .s200, headers: [], body: Data())
        
        
        
        /// verify success is returned
        internetChecker.check(completionHandler: {
            result in
            XCTAssertTrue(result)
            expSuccess.fulfill()
        })
        wait(for: [expSuccess], timeout: 10)
        
        
        /// change server response and verify fail was returned
        locaclServerChangingResponse = LocalServer.LocalServerCallBack(statusCode: .s500, headers: [], body: nil)
        internetChecker.check(completionHandler: {
            result in
            XCTAssertFalse(result)
            expFail.fulfill()
        })
        
        wait(for: [expFail], timeout: 10)
        
        addTeardownBlock {
            server.stop()
        }
    }
}
