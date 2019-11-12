//
//  RamCache.swift
//  Zabatnee
//
//  Created by omarHassan on 2/7/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import UIKit



class RamSharedImageCache: RamCacheImageObj {
    
    private var globalImageRam : SyncedDic<ImageUrlWrapper> = SyncedDic<ImageUrlWrapper>()
    
    
    func cache(image: UIImage, url: String) -> Bool {
        
        let queryUrl = PersistentUrl.amazonCheck(url: url)
        globalImageRam.syncedInsert(element: ImageUrlWrapper(url: queryUrl, image: image), completion: {[weak self] in
            guard let ramCache = self else {return}
            if ramCache.globalImageRam.values.count >= 100  {
                ramCache.globalImageRam.updateTimeStamp()
                ramCache.globalImageRam.values = [:]
            }
        })
        
        
        
        
        return true
    }
    
    func getImageFor(url: String) -> UIImage? {
        var resultImage : UIImage? = nil
            let queryUrl = PersistentUrl.amazonCheck(url: url)
            let obj = globalImageRam.syncedRead(targetElementHashValue: queryUrl.hashValue)
            resultImage = obj?.image
        
        return resultImage
    }
}
