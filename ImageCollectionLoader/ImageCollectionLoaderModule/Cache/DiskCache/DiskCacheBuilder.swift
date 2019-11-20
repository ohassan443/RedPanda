//
//  CacheBuilder.swift
//  RedPanda
//
//  Created by Omar Hassan  on 1/28/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation


public class DiskCacheBuilder {
    var cachedImages = SyncedAccessHashableCollection<ImageUrlWrapper>(array: [])
    var fileSystemMock : DiskCacheFileSystemProtocol = DiskCacheFileSystemBuilder().mock()
    
    
    public init(){}
    public func concrete() -> DiskCacheProtocol {
        
        let database = DiskCacheDataBaseBuilder().concrete()
        let realCache = DiskCacheImage(DisckCacheImageDatabase: database, fileSystemImacheCache: DiskCacheFileSystemBuilder().concrete())
        return realCache
    }
    
    func concreteForTesting(DisckCacheImageDatabase: DiskCacheDataBaseProtocol, fileSystemImacheCache: DiskCacheFileSystemProtocol) -> DiskCacheImage {
          return DiskCacheImage(DisckCacheImageDatabase: DisckCacheImageDatabase, fileSystemImacheCache: fileSystemImacheCache)
    }
    
    
    
    
    func emptyMock(storePolicy:DiskCacheImageMock.StorePolicy,queryPolicy:DiskCacheImageMock.QueryPolicy) -> DiskCacheImageMock {
       return DiskCacheImageMock(cachedImages: SyncedAccessHashableCollection<ImageUrlWrapper>(array: []), storePolicy: storePolicy, queryPolicy: queryPolicy)
    }
    
    
    
    func unResponseiveMock() -> DiskCacheImageMock {
        return DiskCacheImageMock(cachedImages: cachedImages, storePolicy: .skip , queryPolicy: .returnNil)
    }
    
    
    
    func mock(storePolicy:DiskCacheImageMock.StorePolicy,queryPolicy:DiskCacheImageMock.QueryPolicy) -> DiskCacheImageMock {
        let cacheMock = DiskCacheImageMock(cachedImages: cachedImages, storePolicy:storePolicy , queryPolicy: queryPolicy)
        return cacheMock
    }
    
    
    
    func with(images:SyncedAccessHashableCollection<ImageUrlWrapper>) -> DiskCacheBuilder {
        self.cachedImages = images
        return self
    }
    
    
    
    func with(fileSystemImageCache:DiskCacheFileSystemProtocol) -> DiskCacheBuilder {
        self.fileSystemMock = fileSystemImageCache
        return self
    }
    
    
    
    
}
