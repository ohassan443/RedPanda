//
//  ExampleUITests.swift
//  ExampleUITests
//
//  Created by Omar Hassan  on 10/23/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest

class ExampleUITests: XCTestCase {

   
    func testExample() {
        
        
        let server = LocallServer.getInstance(response: {
            params , callBack in

            callBack(LocallServer.LocalServerCallBack(statusCode: .redirectToServer, headers: [], body: nil))
      		print(params)
            
        })
        XCUIApplication().launch()
        let exp = expectation(description: "tempp")
        
        
        waitForExpectations(timeout: 1000, handler: nil)
    }

}
