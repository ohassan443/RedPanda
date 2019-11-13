//
//  RamCacheMock.swift
//  Zabatnee
//
//  Created by omarHassan on 2/7/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//


import Foundation
import UIKit




class RamCacheMock: RamCacheProtocol {
    
    /**
     flag added for check on retreive only to mock having an empty cache / full resonsive cache
     */
    
    // how the mock responses in case its 'cache' method is called
    enum StorePolicy {
        case store
        case skip
    }
    /// how the mock responses in case it is queried for an image matching a certain url
    enum QueryPolicy {
        case checkInSet
        case returnNil
    }
    
    private var imageSet = SyncedAccessHashableCollection<ImageUrlWrapper>.init(array: [])
    private var storePolicy: StorePolicy
    private var queryPolicy : QueryPolicy
    
    
    
    init(images:SyncedAccessHashableCollection<ImageUrlWrapper>,storePolicy:StorePolicy,queryPolicy:QueryPolicy) {
        self.imageSet = images
        self.storePolicy = storePolicy
        self.queryPolicy = queryPolicy
    }
    
    
    
    func changeQuery(Policy:QueryPolicy) -> Void {
        self.queryPolicy = Policy
    }
    func changeStore(Policy:StorePolicy) -> Void {
        self.storePolicy = Policy
    }
    
    
    
    func getImageFor(url: String, result: @escaping (UIImage?) -> ()) {
        switch queryPolicy {
        case .returnNil:  result(nil)
            
        case .checkInSet :
            let queryUrl = PersistentUrl.amazonCheck(url: url)
            imageSet.syncedRead(targetElementHashValue: queryUrl.hashValue, result: {
                result($0?.image)
            })
        }
    }
    
    func cache(image: UIImage, url: String, result: @escaping (Bool) -> ()) {
        switch storePolicy{
        case .skip : result(false)
            
        case .store:
            let storageUrl = PersistentUrl.amazonCheck(url: url)
            imageSet.syncedInsert(element: ImageUrlWrapper(url: storageUrl, image: image), completion: {_ in 
                /// synced collection implementation always succeeds , so for now this is always true
                result(true)
            })
        }
    }
    
    
}
