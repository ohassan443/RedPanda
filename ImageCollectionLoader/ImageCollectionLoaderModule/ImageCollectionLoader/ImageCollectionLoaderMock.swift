//
//  TableImageLoaderMock.swift
//  RedPanda
//
//  Created by Omar Hassan  on 2/8/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import UIKit
class ImageCollectionLoaderMock: ImageCollectionLoaderProtocol {
  

    
    
    
    
    
    
    enum Response {
        case success(_ image : UIImage,_ Index:IndexPath,_ requestDate:Date)
        case failed(failedRequest:imageRequest,failedImage: UIImage?,requestState:imageRequest.RequestState.AsynchronousCallBack)
        case returnWithoutEecute(failedRequest:imageRequest,requestState:imageRequest.RequestState.AsynchronousCallBack)
        case none
    }
    
    var response                    : Response = .none
    var connected: Bool             = false
    
   func requestImage(requestDate: Date, url: String, indexPath: IndexPath, tag: String, successHandler: @escaping (UIImage, IndexPath, Date) -> (), failedHandler: ((imageRequest?, UIImage?, imageRequest.RequestState.AsynchronousCallBack) -> ())?) {
        
        
        
        
        switch response {
            
        case .returnWithoutEecute(failedRequest : let failedRequest,requestState: let requestState):
            failedHandler?(failedRequest,nil,requestState)
            return
            
        case .success(let successImage ,let successIndexPath,let successDate):
            
            // imageRequest is hashed by url + tag + indexPath
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                successHandler(successImage,successIndexPath,successDate)
            })
            
        case .failed(failedRequest : let failedRequest, failedImage: let failedImage,let requestState):
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                failedHandler?(failedRequest,failedImage,requestState)
            })
            
        case .none :
            let placeHolderRequest = imageRequest( url: "", loading: false, dateRequestedAt: Date(), cellIndexPath: IndexPath(row: 0, section: 0), tag: "")
            failedHandler?(placeHolderRequest,nil,.invalid)
        }
    }
    
    
    
    func changeTimerRetry(interval: TimeInterval) {}
    
    
    func respondToReachabilityChange(reachable: Bool) {}
    
    
    
    
    
}
