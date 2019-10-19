//
//  CacheMock.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 1/30/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import UIKit

class DiskCacheImageMock: DiskCahceImageObj {
   
    enum StorePolicy {
        case store
        case skip
    }
    enum QueryPolicy {
        case checkInSet
        case returnNil
    }
    
    
    private var list : Set<ImageUrlWrapper> = []
    private var storePolicy: StorePolicy
    private var queryPolicy : QueryPolicy
    
  
    
    init(cachedImages: Set<ImageUrlWrapper>,storePolicy:StorePolicy,queryPolicy:QueryPolicy) {
        self.list = cachedImages
        self.storePolicy = storePolicy
        self.queryPolicy = queryPolicy
    }
    
    
    
    func changeQuery(Policy:QueryPolicy) -> Void {
        self.queryPolicy = Policy
    }
    func changeStore(Policy:StorePolicy) -> Void {
        self.storePolicy = Policy
    }
    
    
    
    
    func getImageFor(url: String, completion: (UIImage?) -> ()) {
     
        switch queryPolicy {
            
        case .returnNil:
            completion(nil)
            return
            
        case .checkInSet :
            let element = ImageUrlWrapper.setContaints(set: list, url: url)
            completion(element?.image)
        }
 }
    
    
    
    
    
    func cache(image: UIImage, url: String, completion: (Bool) -> ()) {
        
        switch storePolicy{
            
        case .skip :
            completion(false)
            return
            
        case .store:
            let insertResult = list.insert(ImageUrlWrapper(url: url, image: image))
            completion( insertResult.inserted)
            
        }
     }
    
    
    
    
    func delete(url: String, completion: (Bool) -> ()) {
        guard let element = ImageUrlWrapper.setContaints(set: list, url: url)else {
            completion(false)
            return
        }
        list.remove(element)
        completion(true)
    }
    func createImagesDirectoryIfNoneExists() {}
    
    func deleteAll() -> Bool {
        list.removeAll()
        return true
    }
    
    func deleteWith(minLastAccessDate: Date, completion: @escaping (Bool) -> ()) {
        let urlsToDelete = list.filter(){
            return $0.getLastAccessDate() < minLastAccessDate
        }
        
        for element in urlsToDelete{
            list.remove(element)
        }
        
        completion(true)
    }
    
 
 }
