//
//  ReachabilityTests.swift
//  RedPandaTests
//
//  Created by Omar Hassan  on 2/3/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest
@testable import ImageCollectionLoader

class RachabailityMonitorMockTests: XCTestCase {

    /// dummy delegate class to test with
    class monitor: ReachabilityMonitorDelegateProtocol {
       
        var connected: Bool
        init(connected:Bool) {
            self.connected = connected
        }
      
        func respondToReachabilityChange(reachable: Bool) {
            //print("reachability status change in monitor")
            self.connected = reachable
        }
    }
    
    
    
    
    func testDelegateBeingNotifiedOnChange() {
        /// create mock to test and the dummy stub delegate
        let reachabilityMonitorMock = ReachabailityMonitorMock(conncection: .none)
        let reachabilityMonitorDelegate = monitor(connected: false)
        
        XCTAssertFalse(reachabilityMonitorDelegate.connected)
        
        
        
        /// assign delegate to mock , change the mock state to cellular, verify that delegate was notified
        reachabilityMonitorMock.set(delegate: reachabilityMonitorDelegate)
        reachabilityMonitorMock.changeConnectionState(newState: .cellular)
         
        XCTAssertEqual(reachabilityMonitorDelegate.connected, true)
        
        
        
        /// modify mock state to none , verify delegate was notified
        reachabilityMonitorMock.changeConnectionState(newState: .none)
         XCTAssertEqual(reachabilityMonitorDelegate.connected, false)
        
        
        /// modify mock state to wifi , verify delegate was notified
        reachabilityMonitorMock.changeConnectionState(newState: .wifi)
         XCTAssertEqual(reachabilityMonitorDelegate.connected, true)
        
    }

}
