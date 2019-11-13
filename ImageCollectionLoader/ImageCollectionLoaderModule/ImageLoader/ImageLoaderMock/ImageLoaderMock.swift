//
//  ImageLoaderMock.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 1/30/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import UIKit



class ImageLoaderMock: ImageLoaderObj {
  
    
 
    
    
    enum ReturnResponse {
        case ramCache
        case diskCache
        case responseImage(image:UIImage)
        case throwError(error:Error)
    }
    
    enum MockError : Error {
        case mockImageUnAvaliable
    }
    
    var diskCache: DiskCacheProtocol
    var ramCache : RamCacheProtocol
    var delay : TimeInterval
    
    var returnType : ReturnResponse
    
    init(diskCache:DiskCacheProtocol,ramCache:RamCacheProtocol,delay:TimeInterval?,returnResponse:ReturnResponse) {
        self.diskCache = diskCache
        self.ramCache = ramCache
        self.delay = delay ?? 0
        self.returnType = returnResponse
    }
    
    func change(returnResponse:ReturnResponse) -> Void {
        self.returnType = returnResponse
    }
    
    func queryRamCacheFor(url: String, result: @escaping (UIImage?) -> ()) {
        ramCache.getImageFor(url: url, result: result)
      }
    
    
    private func cacheToRam(image:UIImage,url:String){
        let urlToCache = PersistentUrl.amazonCheck(url: url)
        _ = ramCache.cache(image: image, url: urlToCache, result: {_ in})
    }
    
    
    
    func getImageFrom(urlString: String, completion: @escaping (UIImage) -> (), fail: @escaping (_ url:String,_ error:Error) -> ()) {
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            [weak self] in
            guard let imageLoader = self else {return}
            
            
            
            
            
            switch imageLoader.returnType{
                
            case .responseImage(image: let responseImage) :
                completion(responseImage)
                return
                
            case .throwError(error: let errorToThrow):
                fail(urlString,errorToThrow)
                return
                
            case.ramCache :
                
                imageLoader.ramCache.getImageFor(url: urlString, result: {
                    image in
                    guard let image = image else {
                        fail(urlString,MockError.mockImageUnAvaliable)
                                          return
                    }
                      completion(image)
                })
                
            case .diskCache:
                
                imageLoader.diskCache.getImageFor(url: urlString, completion: {
                    cachedImage in
                    if let image  = cachedImage {
                        completion(image)
                        return
                    }else {
                        fail(urlString,MockError.mockImageUnAvaliable)
                        return
                    }
                })
            }
        })
    }
}
    
    
    

