//
//  FileSystemImageCacheBuilder.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 2/11/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation

class DiskCacheFileSystemBuilder {
    var cachedImages = SyncedAccessHashableCollection<ImageUrlWrapper>.init(array: [])
    var delay : TimeInterval = 0
    
    
    
    func concrete() -> DiskCacheFileSystem {
         let directoryInCache =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent(Constants.imagesSubDirectoryInCache)
        return DiskCacheFileSystem(directory: directoryInCache)
    }
    func concreteForTestingWithDifferentDirectory(directory:URL) -> DiskCacheFileSystem {
        
        return DiskCacheFileSystem(directory: directory)
        
    }
    
    func mock() -> FileSystemImageCacheMock {
        return FileSystemImageCacheMock(cachedImages: cachedImages,responseDelay:delay)
    }
    
  
    
    func with(images:SyncedAccessHashableCollection<ImageUrlWrapper>) -> DiskCacheFileSystemBuilder {
        self.cachedImages = images
        return self
    }
    func with(delay:TimeInterval)->DiskCacheFileSystemBuilder{
        self.delay = delay
        return self
    }
}
