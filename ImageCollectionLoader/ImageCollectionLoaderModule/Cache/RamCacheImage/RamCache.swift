//
//  RamCache.swift
//  Zabatnee
//
//  Created by omarHassan on 2/7/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import UIKit



class RamCache: RamCacheProtocol {
  
    
    /// synced dictionary to avoid multiple writes crashes
    private var ram : SyncedAccessHashableCollection<ImageUrlWrapper> = SyncedAccessHashableCollection<ImageUrlWrapper>(array: [])
    private var maxCount = 20
    
    // subscribe to didReceiveMemoryWarningNotification to clear ram if memory is overloaded
    init(maxItemsCount : Int) {
        self.maxCount = maxItemsCount
        NotificationCenter.default.addObserver(self, selector: #selector(freeRam), name: UIApplication.didReceiveMemoryWarningNotification , object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
   
    func getImageFor(url: String, result: @escaping (UIImage?) -> ()) {
           let queryUrl = PersistentUrl.amazonCheck(url: url)
        ram.syncedRead(targetElementHashValue: queryUrl.hashValue, result: {
            result($0?.image)
        })
      }
    
    func cache(image: UIImage, url: String, result:  @escaping  (Bool) -> ()) {
        
        let queryUrl = PersistentUrl.amazonCheck(url: url)
        let objToCache = ImageUrlWrapper(url: queryUrl, image: image)
        self.ram.syncedInsert(element: objToCache, maxCountRefresh : maxCount,completion:{_ in
            result(true)
        })
        
    }
    
    /// clear images in ram
     @objc private func freeRam() -> Void {
        ram.refreshAnDiscardQueueUpdates()
    }
    
  
}
