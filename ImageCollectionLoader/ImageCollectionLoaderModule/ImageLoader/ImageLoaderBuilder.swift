//
//  ImageLoaderBuilder.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 1/30/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import UIKit


class ImageLoaderBuilder  {
    
    var delay : TimeInterval = 0
    var diskCache : DiskCahceImageObj = DiskCacheImageBuilder().unResponseiveMock()
    var RamCacheObj : RamCacheImageObj = RamCacheImageBuilder().unResponsiveMock()
    
    
    
    enum ReturnResponse {
        case success(image:UIImage?)
        case fail(error:Error)
    }
    
    
    func concrete() -> ImageLoader {
        let serverLoader = ImageLoader(diskCache: DiskCacheImageBuilder().concrete(), ramCache: RamCacheImageBuilder().sharedConcrete())
        return serverLoader
    }
    
    /**
     this loader will use the disk and ram cache provided in the builder,but will  use the network to request the image from the internet if not found in the provided caches
     */
    func customConcrete() -> ImageLoader {
        return ImageLoader(diskCache: self.diskCache, ramCache: self.RamCacheObj)
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
    func with(ramCache:RamCacheImageObj)->ImageLoaderBuilder{
        self.RamCacheObj = ramCache
        return self
    }
    func with(diskCache:DiskCahceImageObj) -> ImageLoaderBuilder {
        self.diskCache = diskCache
        return self
    }
}
