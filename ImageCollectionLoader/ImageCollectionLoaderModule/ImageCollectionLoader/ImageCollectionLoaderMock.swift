//
//  TableImageLoaderMock.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 2/8/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import UIKit
class ImageCollectionLoaderMock: ImageCollectionLoaderObj {
    
    
    
    
    
    enum Response {
        case success(_ image : UIImage,_ Index:IndexPath,_ requestDate:Date,requestState:imageRequest.RequestState.AsynchronousCallBack)
        case failed(failedRequest:imageRequest,failedImage: UIImage?,requestState:imageRequest.RequestState.AsynchronousCallBack)
        case returnWithoutEecute(requestState:imageRequest.RequestState.AsynchronousCallBack)
        case none
    }
    
    var response                    : Response = .none
    var cacheQueryState             : (imageRequest.RequestState.SynchronousCheck,UIImage?) = (.notAvaliable,nil)
    var connected: Bool             = false
    
    func requestImage(requestDate: Date, url: String, indexPath: IndexPath, tag: String
        , successHandler: @escaping (UIImage, IndexPath,Date) -> ()
        , failedHandler: ((_ failedRequest:imageRequest,_ image:UIImage?)->())?
    ) -> imageRequest.RequestState.AsynchronousCallBack {
        
        
        
        
        switch response {
            
        case .returnWithoutEecute(requestState: let requestState):
            return requestState
            
        case .success(let successImage ,let successIndexPath,let successDate,let successRequestState):
            
            // imageRequest is hashed by url + tag + indexPath
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                successHandler(successImage,successIndexPath,successDate)
            })
            return successRequestState
            
        case .failed(failedRequest : let failedRequest, failedImage: let failedImage,let requestState):
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                failedHandler?(failedRequest,failedImage)
            })
            return requestState
            
        case .none :
            return imageRequest.RequestState.AsynchronousCallBack.invalid
        }
    }
    
    
    
    func changeTimerRetry(interval: TimeInterval) {}
    
    
    func cacheQueryState(url: String) -> (state:imageRequest.RequestState.SynchronousCheck,image:UIImage?) {
        return cacheQueryState
    }
    
    func respondToReachabilityChange(reachable: Bool) {}
    
    
    
    
    
}
