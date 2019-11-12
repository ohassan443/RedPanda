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
        let sharedRamCache = RamCacheBuilder().concrete(maxItemsCount: 50)
        
        
        
        let preCacheResult = sharedRamCache.getImageFor(url: url)
        XCTAssertNil(preCacheResult)
        
        
        let cacheResult = sharedRamCache.cache(image: testImage, url: url)
        XCTAssertEqual(cacheResult, true)
        
        
        let cachedImage = sharedRamCache.getImageFor(url: url)
        XCTAssertNotNil(cachedImage)
        XCTAssertEqual(cachedImage!.pngData(), testImage.pngData())
    }

    /// when the ram reaches the max count , it deletes all images
    func testRamReachedMaxCount() {
        let testImage = testImage1
        let sharedRamCache = RamCacheBuilder().concrete(maxItemsCount: 50)
        
        
        func geturl(i:Int)-> String{
            return "url = \(i)"
        }
        
        for i in 0...52 {
            sharedRamCache.cache(image: testImage, url: geturl(i: i))
        }
       
        
        
        let expVerifiedResults = expectation(description: "verified first image was deleted and last image was found ")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
             let image = sharedRamCache.getImageFor(url: geturl(i: 0))
            XCTAssertNil(image)
            
            let lastImage = sharedRamCache.getImageFor(url: geturl(i: 51))
            XCTAssertNil(lastImage)
            expVerifiedResults.fulfill()
        })
        
        waitForExpectations(timeout: 3, handler: nil)
        
    }
    
}
