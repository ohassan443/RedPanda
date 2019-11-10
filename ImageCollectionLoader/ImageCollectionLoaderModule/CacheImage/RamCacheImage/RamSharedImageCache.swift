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
    
    static private var globalImageRam : SyncedDic<ImageUrlWrapper> = SyncedDic<ImageUrlWrapper>()
    private let queue = DispatchQueue(label: "sharedRamCacheQueue \(Date().timeIntervalSince1970)", qos: .userInitiated)
    
    func cache(image: UIImage, url: String) -> Bool {
        var inserted = false
        queue.sync {
            let queryUrl = PersistentUrl.amazonCheck(url: url)
            RamSharedImageCache.globalImageRam.syncedInsert(element: ImageUrlWrapper(url: queryUrl, image: image), completion: {})
            inserted = true
        }
        return inserted
    }
    
    func getImageFor(url: String) -> UIImage? {
        var resultImage : UIImage? = nil
        queue.sync {
            let queryUrl = PersistentUrl.amazonCheck(url: url)
            let obj = RamSharedImageCache.globalImageRam.syncedRead(targetElementHashValue: queryUrl.hashValue)
            resultImage = obj?.image
        }
        return resultImage
    }
}
