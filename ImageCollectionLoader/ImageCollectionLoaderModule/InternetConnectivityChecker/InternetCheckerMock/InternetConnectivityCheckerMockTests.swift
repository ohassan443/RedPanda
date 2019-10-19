//
//  InternetConnectivityCheckerTest.swift
//  ZabatneeTests
//
//  Created by Omar Hassan  on 2/3/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest
@testable import Zabatnee


class InternetConnectivityCheckerMockTests: XCTestCase {
    
    
    
    // test checkMock returning response on correctThread
    func testCorrectBehaviour() {
        let MainTrueMock = InternetConnectivityCheckerBuilder()
            .with(returnQueue: .Main)
            .with(successResponse: true)
            .Mock()
        let mainTrueExp = expectation(description: "MainTrue")
        MainTrueMock.check(completionHandler: {
            result in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertTrue(result)
            mainTrueExp.fulfill()
        })
        
        
        
        let mainFalseExp = expectation(description: "MainFalse")
        let mainFalseMock = InternetConnectivityCheckerBuilder()
            .with(returnQueue: .Main)
            .with(successResponse: false)
            .Mock()
        mainFalseMock.check(completionHandler: {
            result in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertFalse(result)
            mainFalseExp.fulfill()
        })
        
        
        
        let globalTrueExp = expectation(description: "GlobalTrue")
        let globalTrue = InternetConnectivityCheckerBuilder()
            .with(returnQueue: .Global)
            .with(successResponse: true)
            .Mock()
        
        globalTrue.check(completionHandler: {
            result in
            XCTAssertFalse(Thread.isMainThread)
            XCTAssertTrue(result)
            globalTrueExp.fulfill()
        })
        
        
        
        let globalFalseExp = expectation(description: "GlobalFalse")
        let globalFalse = InternetConnectivityCheckerBuilder()
            .with(returnQueue: .Global)
            .with(successResponse: false)
            .Mock()
        globalFalse.check(completionHandler: {
            result in
            XCTAssertFalse(Thread.isMainThread)
            XCTAssertFalse(result)
            globalFalseExp.fulfill()
        })
        
        
        
        
        let failedExp = expectation(description: "failed")
        let failedTest = InternetConnectivityCheckerBuilder()
            .with(returnQueue: .Global)
            .with(successResponse: false)
            .Mock()
        failedTest.check(completionHandler: {
            result in
            
            XCTAssertFalse(Thread.isMainThread)
            XCTAssertNotEqual(result, true)
            failedExp.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
    }
    
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
