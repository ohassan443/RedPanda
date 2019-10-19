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
    
    static private var globalImageRam : Set<ImageUrlWrapper> = []
    private let queue = DispatchQueue(label: "sharedRamCacheQueue \(Date().timeIntervalSince1970)", qos: .userInitiated)
    
    func cache(image: UIImage, url: String) -> Bool {
        var inserted = false
        queue.sync {
            let queryUrl = PersistentUrl.amazonCheck(url: url)
            let result =    RamSharedImageCache.globalImageRam.insert(ImageUrlWrapper(url: queryUrl, image: image))
            inserted = result.inserted
        }
        return inserted
    }
    
    func getImageFor(url: String) -> UIImage? {
        var resultImage : UIImage? = nil
        queue.sync {
            let queryUrl = PersistentUrl.amazonCheck(url: url)
            let obj = RamSharedImageCache.globalImageRam.filter(){
                $0.url == queryUrl
                }.first
            resultImage =  obj?.image
        }
        return resultImage
    }
}
