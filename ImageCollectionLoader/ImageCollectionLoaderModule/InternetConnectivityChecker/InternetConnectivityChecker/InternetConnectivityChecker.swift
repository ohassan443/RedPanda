//
//  InternetConnectivityChecker.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 2/3/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation


class  InternetConnectivityChecker : InternetCheckerProtocol  {

    private var url : String
    private var pendingCompletionHandler : [(Bool)->()] = []
    init(url:String) {
        self.url = url
    }
    private var lock = DispatchSemaphore(value: 1)
  /**
     ping a url and return success if the response is 200
     */
    func check(completionHandler: @escaping (Bool) -> Void) ->(){
        
        guard let url = URL(string: url) else {
            completionHandler(false)
            //print("could not create url from: \(webAddress)")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            guard error == nil else {
                completionHandler(false)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                completionHandler(false)
                return
            }
            
            guard statusCode == 200 else {
                completionHandler(false)
                return
            }
            
            completionHandler(true)
            
        })
        task.resume()
    }
}

