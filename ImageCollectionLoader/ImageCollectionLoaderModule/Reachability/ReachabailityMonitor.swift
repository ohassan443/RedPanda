//
//  Reachability.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 1/30/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import Reachability

/// monitor reachability status and notify the delegate on change 
class ReachabailityMonitor: ReachabilityMonitorProtocol {
   
    
    var reachabilityMonitorDelegate: ReachabilityMonitorDelegateProtocol?
    var reachability = Reachability(hostname: "www.google.com")!
    
    
    init() {
       
        NotificationCenter.default.addObserver(self, selector: #selector(MonitorReachabailityStatus), name: Notification.Name.reachabilityChanged , object: nil)
        try? self.reachability.startNotifier()
    }
    deinit {
        self.reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self)
    }
    func set(delegate: ReachabilityMonitorDelegateProtocol) {
        weak var weakDelegate = delegate
        self.reachabilityMonitorDelegate = weakDelegate
    }
    
    
    @objc private func MonitorReachabailityStatus() -> Void {
        
        let connectable =   reachability.connection != .none
        reachabilityMonitorDelegate?.respondToReachabilityChange(reachable: connectable)
        
    }
  
}



