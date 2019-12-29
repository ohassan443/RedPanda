//
//  TableImageLoaderMock.swift
//  RedPanda
//
//  Created by Omar Hassan  on 2/8/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//


import Foundation
import UIKit
public class ImageCollectionLoaderMock: ImageCollectionLoaderProtocol {
  

    public class params {
      public var requestDate: Date
      public var url: String
      public var indexPath: IndexPath
      public var tag: String
      public var successHandler:  ((UIImage, IndexPath, Date) -> ())?
      public var failedHandler: ((imageRequest?, UIImage?, imageRequest.RequestState.AsynchronousCallBack) -> ())?
        init(
        requestDate             : Date,
        url                     : String,
        indexPath               : IndexPath,
        tag                     : String,
        successHandler          :  ((UIImage, IndexPath, Date) -> ())?,
        failedHandler           : ((imageRequest?, UIImage?, imageRequest.RequestState.AsynchronousCallBack) -> ())?) {
            self.requestDate            = requestDate
            self.url                    = url
            self.indexPath              = indexPath
            self.tag                    = tag
            self.successHandler         = successHandler
            self.failedHandler          = failedHandler
            
        }
    }
    
    
    
    
    
    public enum Response {
        case success(_ image : UIImage,_ Index:IndexPath,_ requestDate:Date)
        case failed(failedRequest:imageRequest,failedImage: UIImage?,requestState:imageRequest.RequestState.AsynchronousCallBack)
        case returnWithoutEecute(failedRequest:imageRequest,requestState:imageRequest.RequestState.AsynchronousCallBack)
        case none
    }
    
    public var response                    : (params)->() = {_ in}
    public var connected: Bool             = false
    
    public func requestImage(requestDate: Date, url: String, indexPath: IndexPath, tag: String, successHandler: @escaping (UIImage, IndexPath, Date) -> (), failedHandler: ((imageRequest?, UIImage?, imageRequest.RequestState.AsynchronousCallBack) -> ())?) {
        response(params.init(requestDate: requestDate, url: url, indexPath: indexPath, tag: tag, successHandler: successHandler, failedHandler: failedHandler))
        
    }
    
    
    
    public func changeTimerRetry(interval: TimeInterval) {}
    
    
    public func respondToReachabilityChange(reachable: Bool) {}
    
    
    
    
    
}
