//
//  InternetConnectivityCheckerTest.swift
//  RedPandaTests
//
//  Created by Omar Hassan  on 2/3/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest
@testable import ImageCollectionLoader


class InternetConnectivityCheckerMockTests: XCTestCase {
    
    
    
    // test checkMock returning response on correctThread
    func testCorrectBehaviour() {
        
        
        /// returned success on the main thread
        let MainTrueMock = InternetConnectivityCheckerBuilder()
            .with(returnQueue: .Main)
            .with(successResponse: true)
            .Mock()
        let expMainSuccess = expectation(description: "MainTrue")
        MainTrueMock.check(completionHandler: {
            result in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertTrue(result)
            expMainSuccess.fulfill()
        })
        
        wait(for: [expMainSuccess], timeout: 1)
        
        
        
         /// returned fail on the main thread
        let expMainFail = expectation(description: "MainFalse")
        let mainFalseMock = InternetConnectivityCheckerBuilder()
            .with(returnQueue: .Main)
            .with(successResponse: false)
            .Mock()
        mainFalseMock.check(completionHandler: {
            result in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertFalse(result)
            expMainFail.fulfill()
        })
        
         wait(for: [expMainFail], timeout: 1)
        
        
         /// returned true on the background thread
        let expGlobalTrue = expectation(description: "GlobalTrue")
        let globalTrue = InternetConnectivityCheckerBuilder()
            .with(returnQueue: .Global)
            .with(successResponse: true)
            .Mock()
        
        globalTrue.check(completionHandler: {
            result in
            XCTAssertFalse(Thread.isMainThread)
            XCTAssertTrue(result)
            expGlobalTrue.fulfill()
        })
        
         wait(for: [expGlobalTrue], timeout: 1)
        
        
        
        /// returned false on the background thread
        let expGlobalFalse = expectation(description: "GlobalFalse")
        let globalFalse = InternetConnectivityCheckerBuilder()
            .with(returnQueue: .Global)
            .with(successResponse: false)
            .Mock()
        globalFalse.check(completionHandler: {
            result in
            XCTAssertFalse(Thread.isMainThread)
            XCTAssertFalse(result)
            expGlobalFalse.fulfill()
        })
        
        
        
        waitForExpectations(timeout: 5, handler: nil)
        
    }
    
    
    /// executes callback  after correct  delay
    func testDelay() -> Void {
        let delayExp = expectation(description: "delay")
        let globalFalse = InternetConnectivityCheckerBuilder()
            .with(returnQueue: .Main)
            .with(successResponse: true)
            .with(delayInterval: 0.1)
            .Mock()
        
        
        let startDate = Date().timeIntervalSince1970
        globalFalse.check(completionHandler: {
            result in
            let executionDate = Date().timeIntervalSince1970
            let delayDiff = executionDate - startDate
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertTrue(result)
            
            //print(delayDiff)
            XCTAssertTrue(delayDiff > 0.1)
            XCTAssertTrue(delayDiff < 1)
            delayExp.fulfill()
        })
        
        
        
        
         waitForExpectations(timeout: 5, handler: nil)
    }
    
    
    
    
    
}
