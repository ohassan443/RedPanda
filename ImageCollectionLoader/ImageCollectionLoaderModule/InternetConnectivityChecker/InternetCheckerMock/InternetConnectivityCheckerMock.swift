//
//  InternetCheckerMock.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 2/3/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation

class InternetConnectivityCheckerMock: InternetConnectivityCheckerObj {
    
    
    enum ReturnQueue {
        case Main
        case Global
    }
    var success : Bool
    var delay : TimeInterval
    var queue : ReturnQueue
    
    init(success:Bool,delay:TimeInterval,returnQueue:ReturnQueue) {
        self.success = success
        self.delay = delay
        self.queue = returnQueue
    }
    
    func change(internetIsAvaliable:Bool) -> Void {
        self.success = internetIsAvaliable
    }
    
    func check(completionHandler: @escaping (Bool) -> Void) {
        var returnQueue : DispatchQueue
        switch queue {
        case .Main:
            returnQueue = DispatchQueue.main
        case .Global :
            returnQueue = DispatchQueue.global()
        }
        
        returnQueue.asyncAfter(deadline: .now() + delay, execute: {[weak self] in
            guard let internetChecker = self else {return}
            completionHandler(internetChecker.success)
        })
        
        
    }
}
