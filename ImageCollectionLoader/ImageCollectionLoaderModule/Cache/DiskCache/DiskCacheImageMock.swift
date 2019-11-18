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
    
    
    private var list = SyncedAccessHashableCollection<ImageUrlWrapper>(array: [])
    private var storePolicy: StorePolicy
    private var queryPolicy : QueryPolicy
    
  
    
    init(cachedImages: SyncedAccessHashableCollection<ImageUrlWrapper>,storePolicy:StorePolicy,queryPolicy:QueryPolicy) {
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
    func getImageFor(url: String, completion: @escaping (UIImage?) -> ()) {
     
        switch queryPolicy {
            
        case .returnNil:
            completion(nil)
            return
            
        case .checkInSet :
            list.syncedRead(targetElementHashValue: url.hashValue, result: {
                completion($0?.image)
            })
        }
 }
    
    
    
    
    /// cache and image & url to the mock list depending on the store policy
    func cache(image: UIImage, url: String, completion: @escaping (Bool) -> ()) {
        
        switch storePolicy{
            
        case .skip :
            completion(false)
            return
            
        case .store:
            list.syncedInsert(element: ImageUrlWrapper(url: url, image: image), completion: {
                result in
                switch result {
                case .success:
                    completion(true)
                case .fail(currentElement: _) :
                    completion(false)
                }
            })
        }
     }
    
    
    
    /// delete specific url from the list if found
    func delete(url: String, completion: @escaping (Bool) -> ()) {
        list.syncedRead(targetElementHashValue: url.hashValue, result: {
            foundElement in
            guard foundElement != nil else {
                completion(false)
                           return
            }
            self.list.syncedRemove(element: ImageUrlWrapper(url: url), completion: {
                completion(true)
            })
            
        })
    }
    
    /**
     delete all images
     */
    func deleteAll() -> Bool {
        list.refreshAnDiscardQueueUpdates()
        return true
    }
    /**
        delete images that were last accessed before  a certain data
        */
    func deleteWith(minLastAccessDate: Date, completion: @escaping (Bool) -> ()) {
        
        let urlsToDelete = list.getValues().filter(){ key,value in
            return value.getLastAccessDate() < minLastAccessDate
        }
        
        var deletedCount = 0
        for element in urlsToDelete{
            list.syncedRemove(element: element.value, completion: {
                deletedCount = deletedCount + 1
                if deletedCount == urlsToDelete.count - 1 {
                     completion(true)
                }
            })
        }
          }
    
 
 }
