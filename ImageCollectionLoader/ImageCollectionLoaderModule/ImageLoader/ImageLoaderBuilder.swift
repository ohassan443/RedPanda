//
//  ImageLoaderBuilder.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 1/30/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import UIKit


public class ImageLoaderBuilder  {
    
    var delay : TimeInterval = 0
    var diskCache : DiskCacheProtocol = DiskCacheBuilder().unResponseiveMock()
    var RamCacheObj : RamCacheProtocol = RamCacheBuilder().unResponsiveMock()
    var urlSession : UrlSessionWrapperProtocol = UrlSessionWrapperMock(placeHolderCallBack: {_ in  print("default url session called in imageLoader builder")  })
    
    
    public init() {
    }
    
    enum ReturnResponse {
        case success(image:UIImage?)
        case fail(error:Error)
    }
    
    
    public func concrete(ramMaxItemsCount:Int) -> ImageLoaderProtocol {
        let serverLoader = ImageLoader(diskCache: DiskCacheBuilder().concrete(), ramCache: RamCacheBuilder().concrete(maxItemsCount: ramMaxItemsCount), urlSession: UrlSessionWrapper())
        return serverLoader
    }
    
    /**
     this loader will use the disk and ram cache provided in the builder,but will  use the network to request the image from the internet if not found in the provided caches
     */
    func customConcrete() -> ImageLoader {
        return ImageLoader(diskCache: self.diskCache, ramCache: self.RamCacheObj, urlSession: urlSession)
    }
    
    /**
     * this loader will use the disk and ram cache provided in the builder,but will use the responseImage/error provided to response instead of hitting the internet
     * returning and image or an error depends on the success parameter
     */
    func loaderMock(response:ImageLoaderMock.ReturnResponse) -> ImageLoaderMock {
        
        return ImageLoaderMock(diskCache: diskCache, ramCache: RamCacheObj, delay: delay, returnResponse: response)
    }
    
    
    func defaultErrorMock() -> ImageLoaderMock {
        
        let returnResponse = ImageLoaderMock.ReturnResponse.throwError(error: imageLoadingError.networkError)
        
        return ImageLoaderMock(diskCache: diskCache, ramCache: RamCacheObj, delay: delay , returnResponse: returnResponse)
    }
    
    func with(delayInterval:TimeInterval) -> ImageLoaderBuilder {
        self.delay = delayInterval
        return self
    }
    func with(ramCache:RamCacheProtocol)->ImageLoaderBuilder{
        self.RamCacheObj = ramCache
        return self
    }
    func with(diskCache:DiskCacheProtocol) -> ImageLoaderBuilder {
        self.diskCache = diskCache
        return self
    }
    func with(urlSession:UrlSessionWrapperProtocol) -> ImageLoaderBuilder {
        self.urlSession = urlSession
        return self
    }
}
