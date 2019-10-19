//
//  InternetConnectivityChecker.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 2/3/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation

class  InternetConnectivityChecker : InternetConnectivityCheckerObj  {

    let webAddress = "https://www.google.com" // Default Web Site
    func check(completionHandler: @escaping (Bool) -> Void) ->(){
        guard let url = URL(string: webAddress) else {
            completionHandler(false)
            //print("could not create url from: \(webAddress)")
            completionHandler(false)
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if error != nil || response == nil {
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        })
        task.resume()
    }
}

