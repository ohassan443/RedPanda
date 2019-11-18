//
//  ImageLoaderurlSession.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 1/30/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation


class UrlSessionWrapper : UrlSessionWrapperProtocol{
    private var  session : URLSession
    init() {
           let config = URLSessionConfiguration.default
           config.timeoutIntervalForRequest = 60
           session = URLSession(configuration: config)
    }
    func dataTask(withUrl:String,completionHandler : @escaping (Data?,URLResponse?,Error?)->()) -> URLSessionDataTask? {
        guard let url = URL(string: withUrl)else {
            completionHandler(nil,nil,URLError.init(URLError.unsupportedURL))
            return nil
        }
       return session.dataTask(with: url, completionHandler: completionHandler)
    }
}



class UrlSessionWrapperMock:  UrlSessionWrapperProtocol {
    
    class CallParams  {
        var url : String
        var callBack : ( Data?, URLResponse?, Error?)->()
        
        init(url:String, callBack : @escaping ( Data?, URLResponse?, Error?)->()  ) {
            self.url = url
            self.callBack = callBack
        }
    }
    
    
    private var placeHolderCallBack : (CallParams)->()
  
    
    init(placeHolderCallBack : @escaping (CallParams)->() )  {
        self.placeHolderCallBack = placeHolderCallBack
    }
   
    func dataTask(withUrl: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) -> URLSessionDataTask? {
        placeHolderCallBack(CallParams(url: withUrl, callBack: completionHandler))
        return nil
    }
    
    
}

class UrlSessionWrapperBuilder {
    func concrete() -> UrlSessionWrapperProtocol {
        UrlSessionWrapper()
    }
    
    func mock(placeHolderCallBack : @escaping (UrlSessionWrapperMock.CallParams)->() ) -> UrlSessionWrapperMock {
        UrlSessionWrapperMock(placeHolderCallBack: placeHolderCallBack)
    }
}
