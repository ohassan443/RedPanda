//
//  ReachabilityMock.swift
//  RedPanda
//
//  Created by Omar Hassan  on 2/3/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import Reachability

class ReachabailityMonitorMock:  ReachabilityMonitorProtocol{
    
    
    var reachabilityMonitorDelegate: ReachabilityMonitorDelegateProtocol?
    var connectionState : Reachability.Connection?
    
    
    init(conncection:Reachability.Connection) {
        self.connectionState = conncection
    }
    
    func set(delegate: ReachabilityMonitorDelegateProtocol) {
        weak var weakDelegate = delegate
        self.reachabilityMonitorDelegate = weakDelegate
    }
    
    func changeConnectionState(newState:Reachability.Connection) -> Void {
        self.connectionState = newState
        
        let connected = (newState != .none)
        notifyObserver(connected: connected)
    }
    
    func notifyObserver(connected:Bool) -> Void {
        reachabilityMonitorDelegate?.respondToReachabilityChange(reachable: connected)
    }
}
