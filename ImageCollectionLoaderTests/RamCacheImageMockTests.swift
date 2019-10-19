//
//  RamCacheImageMockTests.swift
//  ZabatneeTests
//
//  Created by Omar Hassan  on 2/13/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest

@testable import Zabatnee
class RamCacheImageMockTests: XCTestCase {

    func testBasicCachingAndQuerying() {
        let normalUrl = "testUrl"
        let amazonUrl =  getTempAmazonUrlfrom(url: "amazonTempUrl")
        
        testBasicCachingAndQueryingFor(url: normalUrl)
        testBasicCachingAndQueryingFor(url: amazonUrl)
        
    }
    func testBasicCachingAndQueryingFor(url:String) -> Void {
        let testImage = UIImage(named: "testImage1")!
       
        let mockRamCache = RamCacheImageBuilder().mock(storePolicy: .store, queryPolicy: .checkInSet)
        
        
        
        let preCacheResult = mockRamCache.getImageFor(url: url)
        XCTAssertNil(preCacheResult)
        
        
        let cacheResult = mockRamCache .cache(image: testImage, url: url)
        XCTAssertEqual(cacheResult, true)
        
        
        let cachedImage = mockRamCache .getImageFor(url: url)
        XCTAssertNotNil(cachedImage)
        XCTAssertEqual(UIImagePNGRepresentation(cachedImage!), UIImagePNGRepresentation(testImage))
    }
    
    
    
    
    
    func testStorePolicy() {
        let normalUrl = "testUrl"
        let amazonUrl =  getTempAmazonUrlfrom(url: "amazonTempUrl")
        
        testStorePolicyFor(url: normalUrl)
        testStorePolicyFor(url: amazonUrl)
    }
    
    func testStorePolicyFor(url:String) {
        let testImage = UIImage(named: "testImage1")!
        
     
        
        let mockRamCache = RamCacheImageBuilder()
            .with(imageSet: [])
            .mock(storePolicy: .skip, queryPolicy: .checkInSet)
        
        let cacheResult = mockRamCache.cache(image: testImage, url: url)
        XCTAssertEqual(cacheResult, false)
        
        let cachedImage = mockRamCache.getImageFor(url: url)
        XCTAssertNil(cachedImage)
        
        mockRamCache.changeStore(Policy: .store)
        
        let secondcacheResult = mockRamCache.cache(image: testImage, url: url)
        XCTAssertEqual(secondcacheResult, true)
        
        let secondCachedImage = mockRamCache.getImageFor(url: url)
        XCTAssertNotNil(secondCachedImage)
      
    }
    
    
    
    func testReadPolicyPolicy() {
        let normalUrl = "testUrl"
        let amazonUrl =  getTempAmazonUrlfrom(url: "amazonTempUrl")
        
        testStorePolicyFor(url: normalUrl)
        testStorePolicyFor(url: amazonUrl)
    }
    
    func testReadPolicyFor(url:String) {
        let testImage = UIImage(named: "testImage1")!
        
        let imageSet : Set<ImageUrlWrapper> = [ImageUrlWrapper(url: url, image: testImage)]
        
        let mockRamCache = RamCacheImageBuilder()
            .with(imageSet: imageSet)
            .mock(storePolicy: .skip, queryPolicy: .returnNil)
        
        let firstQueryImage = mockRamCache.getImageFor(url: url)
        XCTAssertNil(firstQueryImage)
        
        
        
         mockRamCache.changeQuery(Policy: .checkInSet)
        
        let secondQueryImage = mockRamCache.getImageFor(url: url)
        XCTAssertNotNil(secondQueryImage)
        XCTAssertEqual(UIImagePNGRepresentation(secondQueryImage!), UIImagePNGRepresentation(testImage))
    
    }
    
    
    
    
    
    
    
    
}
