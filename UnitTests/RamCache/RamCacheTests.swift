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
        
        
        let expLoadedSuccessfully = expectation(description: " Loaded Image Successfully after caching it ")
        sharedRamCache.getImageFor(url: url, result: {
            preCacheResult in
            XCTAssertNil(preCacheResult)
            
            sharedRamCache.cache(image: testImage, url: url,result: {
                cacheResult in
                XCTAssertEqual(cacheResult, true)
                
                sharedRamCache.getImageFor(url: url, result: {
                    cachedImage in
                    XCTAssertNotNil(cachedImage)
                    if let cached = cachedImage{
                        
                        XCTAssertEqual(cached.pngData(), testImage.pngData())
                        expLoadedSuccessfully.fulfill()
                    }
                    
                })
            })
        })
        waitForExpectations(timeout: 1, handler: nil)
    }

    /// when the ram reaches the max count , it deletes all images
    func testRamReachedMaxCount() {
        let testImage = testImage1
        let sharedRamCache = RamCacheBuilder().concrete(maxItemsCount: 500)
        let expVerifiedResults = expectation(description: "verified first image was deleted and last image was found ")
        
        func geturl(i:Int)-> String{
            return "url = \(i)"
        }
        
        let semaphore = DispatchSemaphore(value: 1)
        var fullfilled = false
        let lastFiftyUrl     : [Int] = Array(950...999)
        let lastFiftyUrlSet  = Set(lastFiftyUrl.map(){return $0})
        var cachedUrls       : Set<Int> = []
        let expCachedAllImages = expectation(description: "cached all images successfully")
        for i in 0...999 {
            let url = geturl(i: i)
            sharedRamCache.cache(image: testImage, url: url, result: {
                result in
                XCTAssertTrue(result)
              
                semaphore.wait()
                cachedUrls.insert(i)
                guard fullfilled == false else {return}
                if cachedUrls.isSuperset(of: lastFiftyUrlSet) {
                    fullfilled = true
                    expCachedAllImages.fulfill()
                }
                semaphore.signal()
            })
        }
       
        
        wait(for: [expCachedAllImages], timeout: 5)
        sharedRamCache.getImageFor(url: geturl(i: 0), result: {
            image in
            XCTAssertNil(image)
            
            
            sharedRamCache.getImageFor(url: geturl(i: 900), result: {
                lastImage in
                /// at the 50 image the ram was refreshed
                XCTAssertNotNil(lastImage)
                expVerifiedResults.fulfill()
            })
            
        })
        
        
        
            
          
          
        
        
        waitForExpectations(timeout: 10, handler: nil)
        
    }
    
}
