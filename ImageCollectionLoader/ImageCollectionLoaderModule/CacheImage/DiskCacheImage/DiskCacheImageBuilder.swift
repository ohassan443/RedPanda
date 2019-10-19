//
//  CacheBuilder.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 1/28/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation


class DiskCacheImageBuilder {
    var cachedImages : Set<ImageUrlWrapper> = []
    var fileSystemMock : FileSystemImageCacheObj = FileSystemImageCacheBuilder().mock()
    
    func concrete() -> DiskCacheImage {
        
        let database = DiskCacheImageDataBaseBuilder().concrete()
        let realCache = DiskCacheImage(DisckCacheImageDatabase: database, fileSystemImacheCache: FileSystemImageCacheBuilder().concrete())
        return realCache
    }
    
    func concreteForTesting(DisckCacheImageDatabase: DiskCacheImageDataBaseObj, fileSystemImacheCache: FileSystemImageCacheObj) -> DiskCacheImage {
          return DiskCacheImage(DisckCacheImageDatabase: DisckCacheImageDatabase, fileSystemImacheCache: fileSystemImacheCache)
    }
    
    
    
    
    func emptyMock(storePolicy:DiskCacheImageMock.StorePolicy,queryPolicy:DiskCacheImageMock.QueryPolicy) -> DiskCacheImageMock {
       return DiskCacheImageMock(cachedImages: [], storePolicy: storePolicy, queryPolicy: queryPolicy)
    }
    
    
    
    func unResponseiveMock() -> DiskCacheImageMock {
        return DiskCacheImageMock(cachedImages: cachedImages, storePolicy: .skip , queryPolicy: .returnNil)
    }
    
    
    
    func mock(storePolicy:DiskCacheImageMock.StorePolicy,queryPolicy:DiskCacheImageMock.QueryPolicy) -> DiskCacheImageMock {
        let cacheMock = DiskCacheImageMock(cachedImages: cachedImages, storePolicy:storePolicy , queryPolicy: queryPolicy)
        return cacheMock
    }
    
    
    
    func with(images:Set<ImageUrlWrapper>) -> DiskCacheImageBuilder {
        self.cachedImages = images
        return self
    }
    
    
    
    func with(fileSystemImageCache:FileSystemImageCacheObj) -> DiskCacheImageBuilder {
        self.fileSystemMock = fileSystemImageCache
        return self
    }
    
    
    
    
}
