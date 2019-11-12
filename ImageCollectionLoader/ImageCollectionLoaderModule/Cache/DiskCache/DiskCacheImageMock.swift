//
//  CacheMock.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 1/30/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import UIKit

class DiskCacheImageMock: DiskCacheProtocol {
   
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
    
    
    /// change the behaviour for quering the mock for an image for certain url
    func changeQuery(Policy:QueryPolicy) -> Void {
        self.queryPolicy = Policy
    }
    /// change the storing behaviour of the mock
    func changeStore(Policy:StorePolicy) -> Void {
        self.storePolicy = Policy
    }
    
    
    
    /// fetch and image from the mock list if avaliable depending on the query policy
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
    
    
    
    
    /// cache and image & url to the mock list depending on the store policy
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
    
    
    
    /// delete specific url from the list if found
    func delete(url: String, completion: (Bool) -> ()) {
        guard let element = ImageUrlWrapper.setContaints(set: list, url: url)else {
            completion(false)
            return
        }
        list.remove(element)
        completion(true)
    }
    
    /**
     delete all images
     */
    func deleteAll() -> Bool {
        list.removeAll()
        return true
    }
    /**
        delete images that were last accessed before  a certain data
        */
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
