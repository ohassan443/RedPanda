//
//  UITestsConstants.swift
//  ZabatneeUITests
//
//  Created by omarHassan on 8/26/19.
//  Copyright © 2019 omar hammad. All rights reserved.
//

import Foundation
class UITestsConstants {
    enum testingState {
        case testUI
        case viewAppRunning
    }
    
    static let baseUrl = "http://[::1]:8080/"
    static let baseUrlKey = "base_url"
    static let port = 8080
    static let testRunState : testingState = .testUI
}


