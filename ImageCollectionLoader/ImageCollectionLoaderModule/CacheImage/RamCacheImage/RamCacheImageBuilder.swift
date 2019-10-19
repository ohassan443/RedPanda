//
//  RamCacheImageBuilder.swift
//  Zabatnee
//
//  Created by omarHassan on 2/12/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
class RamCacheImageBuilder  {
    private var imageSet : Set<ImageUrlWrapper> = []
    
    func sharedConcrete() -> RamSharedImageCache {
        return RamSharedImageCache()
    }
    
    /**
     - storePolicy : how the mock will behave when asked to cache an image (check enum for cases)
     - queryPolicy : how the mock will respond when asked for specifc url (check enum for cases)
     */
    func mock(storePolicy:RamCacheImageMock.StorePolicy,queryPolicy:RamCacheImageMock.QueryPolicy)-> RamCacheImageMock {
        return RamCacheImageMock(images: imageSet, storePolicy: storePolicy, queryPolicy: queryPolicy)
    }
    
    /**
     - a mock that will not insert images into its set when asked to cache an image & url
     - a mock that will always return nil when queryed for an image
     */
    func unResponsiveMock() -> RamCacheImageMock {
         return RamCacheImageMock(images: imageSet, storePolicy: .skip, queryPolicy: .returnNil)
    }
    
    func with(imageSet:Set<ImageUrlWrapper>) -> RamCacheImageBuilder {
        self.imageSet = imageSet
        return self
    }
 
}
