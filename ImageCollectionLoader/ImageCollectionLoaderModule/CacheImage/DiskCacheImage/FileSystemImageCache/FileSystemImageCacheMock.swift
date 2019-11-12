//
//  FileSystemImageCacheMock.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 2/8/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import UIKit




class FileSystemImageCacheMock: FileSystemImageCacheObj {
   
    
    var cachedImages : Set<ImageUrlWrapper> = []
    var delay : TimeInterval
    
    
    init(cachedImages : Set<ImageUrlWrapper> ,responseDelay : TimeInterval) {
        self.cachedImages = cachedImages
        self.delay = responseDelay
    }
    func writeToFile(image: UIImage, url: String, completion: @escaping (Bool) -> ()) {
        
        fileSystemQueue.asyncAfter(deadline: .now() + delay, execute: {[weak self] in
            
            guard let mock = self else {return}
            let newMember = ImageUrlWrapper(url: url, image: image)
            let inserted = mock.cachedImages.insert(newMember)
            completion(inserted.inserted)
        })
    }
    
    
    
    
    
    
    func readFromFile(url: String, completion: @escaping (UIImage?) -> ()) {
        
        fileSystemQueue.asyncAfter(deadline: .now() + delay, execute: {[weak self] in
            
            guard let mock = self else {return}
            
            let result = mock.cachedImages.filter(){
                return $0.url == url
                }.first
            completion(result?.image)
        })
    }
    
    
    
    
    func deleteFromFile(url: String, completion: @escaping (Bool) -> ()) {
        fileSystemQueue.asyncAfter(deadline: .now() + delay, execute: {[weak self] in
            
            guard let mock = self else {return}
            
            mock.cachedImages.remove(ImageUrlWrapper(url: url))
            completion(true) // completes with true wether the url was in set or not as it is deleted any way
        })
    }
    
    
    func deleteFilesWith(urls: [String], completion: @escaping (Bool) -> ()) {
        fileSystemQueue.asyncAfter(deadline: .now() + delay, execute: {
            
            urls.forEach(){
                self.cachedImages.remove(ImageUrlWrapper(url: $0))
            }
            completion(true) // completes with true wether the urls were in set or not as it is deleted any way
        })
    }
    
    
    
    
    
    func deleteAll() -> Bool {
        cachedImages.removeAll()
        return true
    }
    
}
