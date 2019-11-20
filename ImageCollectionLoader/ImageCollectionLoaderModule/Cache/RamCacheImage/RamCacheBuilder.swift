//
//  RamCacheBuilder.swift
//  RedPanda
//
//  Created by omarHassan on 2/12/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
public class RamCacheBuilder  {
    private var imageSet = SyncedAccessHashableCollection<ImageUrlWrapper>(array: [])
    
    
    public init() {
    }
    public func concrete(maxItemsCount:Int) -> RamCacheProtocol {
        return RamCache(maxItemsCount: maxItemsCount)
    }
    
    /**
     - storePolicy : how the mock will behave when asked to cache an image (check enum for cases)
     - queryPolicy : how the mock will respond when asked for specifc url (check enum for cases)
     */
    func mock(storePolicy:RamCacheMock.StorePolicy,queryPolicy:RamCacheMock.QueryPolicy)-> RamCacheMock {
        return RamCacheMock(images: imageSet, storePolicy: storePolicy, queryPolicy: queryPolicy)
    }
    
    /**
     - a mock that will not insert images into its set when asked to cache an image & url
     - a mock that will always return nil when queryed for an image
     */
    func unResponsiveMock() -> RamCacheMock {
         return RamCacheMock(images: imageSet, storePolicy: .skip, queryPolicy: .returnNil)
    }
    
    func with(imageSet:SyncedAccessHashableCollection<ImageUrlWrapper>) -> RamCacheBuilder {
        self.imageSet = imageSet
        return self
    }
 
}
