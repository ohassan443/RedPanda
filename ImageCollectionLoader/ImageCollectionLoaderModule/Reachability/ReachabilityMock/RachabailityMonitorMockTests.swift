//
//  ReachabilityTests.swift
//  ZabatneeTests
//
//  Created by Omar Hassan  on 2/3/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest
@testable import Zabatnee

class RachabailityMonitorMockTests: XCTestCase {

    
    class monitor: ReachabilityMonitorDelegate {
       
        var connected: Bool
        init(connected:Bool) {
            self.connected = connected
        }
      
        func respondToReachabilityChange(reachable: Bool) {
            //print("reachability status change in monitor")
            self.connected = reachable
        }
    }
    
    func testReachabilityMock() {
        
        let mock = ReachabailityMonitorMock(conncection: .none)
        let ReachabilityMonitor = monitor(connected: false)
        
        XCTAssertFalse(ReachabilityMonitor.connected)
        
        mock.set(delegate: ReachabilityMonitor)
       
        mock.changeConnectionState(newState: .cellular)
         
        XCTAssertEqual(ReachabilityMonitor.connected, true)
        
        mock.changeConnectionState(newState: .none)
         XCTAssertEqual(ReachabilityMonitor.connected, false)
        
        
        
        mock.changeConnectionState(newState: .wifi)
         XCTAssertEqual(ReachabilityMonitor.connected, true)
        
        
    }

}
