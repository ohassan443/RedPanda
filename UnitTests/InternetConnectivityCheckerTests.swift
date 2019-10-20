//
//  InternetConnectivityCheckerTests.swift
//  ZabatneeTests
//
//  Created by Omar Hassan  on 2/3/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest
@testable import ImageCollectionLoader

class InternetConnectivityCheckerTests: XCTestCase {

    //this test bings google and will fail if no internet is avaliable on the machine running this test
    func testFunctionality() {
        let internetChecker = InternetConnectivityCheckerBuilder().concrete()
        
        let exp = expectation(description: "bing google")
        internetChecker.check(completionHandler: {
            result in
            XCTAssertTrue(result)
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
