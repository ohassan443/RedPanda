//
//  RamSharedImageCacheTests.swift
//  ZabatneeTests
//
//  Created by Omar Hassan  on 2/13/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest

@testable import ImageCollectionLoader

class RamCacheTests: XCTestCase {

    func testCachingAndQuerying() {
        let normalUrl = "testUrl"
        let amazonUrl =  getTempAmazonUrlfrom(url: "amazonTempUrl")
        
       testCacheAndQueryFor(url: normalUrl)
        testCacheAndQueryFor(url: amazonUrl)
        
    }
    func testCacheAndQueryFor(url:String) -> Void {
        let testImage = testImage1
         let sharedRamCache = RamCacheBuilder().concrete()
        
        
        
        let preCacheResult = sharedRamCache.getImageFor(url: url)
        XCTAssertNil(preCacheResult)
        
        
        let cacheResult = sharedRamCache.cache(image: testImage, url: url)
        XCTAssertEqual(cacheResult, true)
        
        
        let cachedImage = sharedRamCache.getImageFor(url: url)
        XCTAssertNotNil(cachedImage)
        XCTAssertEqual(cachedImage!.pngData(), testImage.pngData())
    }

    
    
}
