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
    private var ram : SyncedAccessHashableCollection<ImageUrlWrapper> = SyncedAccessHashableCollection<ImageUrlWrapper>()
    private var maxCount = 20
    
    // subscribe to didReceiveMemoryWarningNotification to clear ram if memory is overloaded
    init(maxItemsCount : Int) {
        self.maxCount = maxItemsCount
        NotificationCenter.default.addObserver(self, selector: #selector(freeRam), name: UIApplication.didReceiveMemoryWarningNotification , object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
   
    
    
    /// add image to the synced collection
    func cache(image: UIImage, url: String) -> Bool {
        
        let queryUrl = PersistentUrl.amazonCheck(url: url)
        ram.syncedInsert(element: ImageUrlWrapper(url: queryUrl, image: image), completion: {[weak self] in
            guard let ramCache = self else {return}
            if ramCache.ram.values.count >= ramCache.maxCount  {
                ramCache.freeRam()
            }
        })
        return true
    }
    
    /// clear images in ram
     @objc private func freeRam() -> Void {
        ram.updateTimeStamp()
        ram.values = [:]
    }
    
    /// query the ram collection for an image corresponding to a url
    func getImageFor(url: String) -> UIImage? {
        var resultImage : UIImage? = nil
            let queryUrl = PersistentUrl.amazonCheck(url: url)
            let obj = ram.syncedRead(targetElementHashValue: queryUrl.hashValue)
            resultImage = obj?.image
        
        return resultImage
    }
}
