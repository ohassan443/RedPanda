//
//  FileSystemImageCacheBuilder.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 2/11/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation

class FileSystemImageCacheBuilder {
    var cachedImages : Set<ImageUrlWrapper> = []
    var delay : TimeInterval = 0
    
    
    
    func concrete() -> FileSystemImageCache {
         let directoryInCache =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent(AppConstants.imagesSubDirectoryInCache)
        return FileSystemImageCache(directory: directoryInCache)
    }
    func concreteForTestingWithDifferentDirectory(directory:URL) -> FileSystemImageCache {
        
        return FileSystemImageCache(directory: directory)
        
    }
    
    func mock() -> FileSystemImageCacheMock {
        return FileSystemImageCacheMock(cachedImages: cachedImages,responseDelay:delay)
    }
    
  
    
    func with(images:Set<ImageUrlWrapper>) -> FileSystemImageCacheBuilder {
        self.cachedImages = images
        return self
    }
    func with(delay:TimeInterval)->FileSystemImageCacheBuilder{
        self.delay = delay
        return self
    }
}
