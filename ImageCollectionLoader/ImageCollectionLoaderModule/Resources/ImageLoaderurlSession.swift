//
//  ImageLoaderurlSession.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 1/30/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation

class imageLoaderUrlSession {
    
    
    static private var session : URLSession! = nil
    
    static func getSession() -> URLSession {
        
        if let staticSession = imageLoaderUrlSession.session{
            return staticSession
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        let session = URLSession(configuration: config)
        imageLoaderUrlSession.session = session
        
        return session
    }
}
