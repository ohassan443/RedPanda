//
//  RamCacheMock.swift
//  Zabatnee
//
//  Created by omarHassan on 2/7/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//


import Foundation
import UIKit




class RamCacheImageMock: RamCacheImageObj {
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
    
    private var imageSet : Set<ImageUrlWrapper> = []
    private var storePolicy: StorePolicy
    private var queryPolicy : QueryPolicy
    
    
    
    init(images:Set<ImageUrlWrapper>,storePolicy:StorePolicy,queryPolicy:QueryPolicy) {
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
    
    
    
    func cache(image: UIImage, url: String) -> Bool {

        switch storePolicy{
      
        case .skip :
            return false
      
        case .store:
            let storageUrl = PersistentUrl.amazonCheck(url: url)
            let result = imageSet.insert(ImageUrlWrapper(url: storageUrl, image: image))
            return result.inserted
        }
    }
    
    func getImageFor(url: String) -> UIImage? {
     
        switch queryPolicy {
            
        case .returnNil:
            return nil
        
        case .checkInSet :
            let queryUrl = PersistentUrl.amazonCheck(url: url)
            let obj = imageSet.filter(){
                $0.url == queryUrl
                }.first
            return obj?.image
        }
    }
}
