//
//  InternetConnectivityCheckerBuilder.swift
//  RedPanda
//
//  Created by Omar Hassan  on 2/3/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation

class InternetConnectivityCheckerBuilder  {
    private var delay : TimeInterval = 0
    private var successResponse : Bool? = false
    private var returnQueue : InternetConnectivityCheckerMock.ReturnQueue? = .Main
    private let webAddress = "https://www.google.com"
    func concrete(url:String? = nil) -> InternetConnectivityChecker {
        return InternetConnectivityChecker( url: url ?? webAddress)
    }
    
    
    
    
    
    func Mock() -> InternetConnectivityCheckerMock {
        return InternetConnectivityCheckerMock(success: successResponse!, delay: delay, returnQueue: returnQueue!)
    }
    
    
    func with(delayInterval:TimeInterval) -> InternetConnectivityCheckerBuilder {
        self.delay = delayInterval
        return self
    }
    
    func with(successResponse:Bool) -> InternetConnectivityCheckerBuilder {
        self.successResponse = successResponse
        return self
    }
    
    func with(returnQueue:InternetConnectivityCheckerMock.ReturnQueue) -> InternetConnectivityCheckerBuilder {
        self.returnQueue = returnQueue
        return self
    }
}









