//
//  FileSystemImageCacheMock.swift
//  RedPanda
//
//  Created by Omar Hassan  on 2/8/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import UIKit




class FileSystemImageCacheMock: DiskCacheFileSystemProtocol {
   
    
    var cachedImages = SyncedAccessHashableCollection<ImageUrlWrapper>(array: [])
    var delay : TimeInterval
    
    
    init(cachedImages : SyncedAccessHashableCollection<ImageUrlWrapper> ,responseDelay : TimeInterval) {
        self.cachedImages = cachedImages
        self.delay = responseDelay
    }
    func writeToFile(image: UIImage, url: String, completion: @escaping (Bool) -> ()) {
        
        fileSystemQueue.asyncAfter(deadline: .now() + delay, execute: {[weak self] in
            
            guard let mock = self else {return}
            let newMember = ImageUrlWrapper(url: url, image: image)
            mock.cachedImages.syncedInsert(element: newMember, completion: {result in
                switch result {
                case .success:
                    completion(true)
                case .fail(currentElement: _) :
                    completion(false)
                }
            })
        })
    }
    
    
    
    
    
    
    func readFromFile(url: String, completion: @escaping (UIImage?) -> ()) {
        
        fileSystemQueue.asyncAfter(deadline: .now() + delay, execute: {[weak self] in
            
            guard let mock = self else {return}
            
            mock.cachedImages.syncedRead(targetElementHashValue: url.hashValue, result: {
                completion($0?.image)
            })
        })
    }
    
    
    
    
    func deleteFromFile(url: String, completion: @escaping (Bool) -> ()) {
        fileSystemQueue.asyncAfter(deadline: .now() + delay, execute: {[weak self] in
            
            guard let mock = self else {return}
            
            mock.cachedImages.syncedRemove(element: ImageUrlWrapper(url: url), completion: {
                 completion(true) // completes with true wether the url was in set or not as it is deleted any way
            })
        })
    }
    
    
    func deleteFilesWith(urls: [String], completion: @escaping (Bool) -> ()) {
        fileSystemQueue.asyncAfter(deadline: .now() + delay, execute: {
            
            var deletedCount = 0
            urls.forEach(){
                self.cachedImages.syncedRemove(element: ImageUrlWrapper(url: $0), completion: {
                     deletedCount = deletedCount + 1
                    if deletedCount == urls.count - 1 {
                          completion(true) // completes with true wether the urls were in set or not as it is deleted any way
                    }
                })
            }
          
        })
    }
    
    
    
    
    
    func deleteAll() -> Bool {
        cachedImages.refreshAnDiscardQueueUpdates()
        return true
    }
    
}
