//
//  RamCacheImageMockTests.swift
//  ZabatneeTests
//
//  Created by Omar Hassan  on 2/13/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest

@testable import ImageCollectionLoader
class RamCacheMockTests: XCTestCase {

    func testBasicCachingAndQuerying() {
        let normalUrl = "testUrl"
        let amazonUrl =  getTempAmazonUrlfrom(url: "amazonTempUrl")
        
        testBasicCachingAndQueryingFor(url: normalUrl)
        testBasicCachingAndQueryingFor(url: amazonUrl)
        
    }
    func testBasicCachingAndQueryingFor(url:String) -> Void {
        let testImage = testImage1
       
        let mockRamCache = RamCacheBuilder().mock(storePolicy: .store, queryPolicy: .checkInSet)
        
        
        let expVerifiedEmptyRam = expectation(description: "imageNotFound initially")
        
        
         mockRamCache.getImageFor(url: url, result: {
            preCacheResult in
            XCTAssertNil(preCacheResult)
            expVerifiedEmptyRam.fulfill()
        })
        wait(for: [expVerifiedEmptyRam], timeout: 1)
        
        
        let expCachedCorrectly = expectation(description: "cached image successfully")
        
        
         mockRamCache .cache(image: testImage, url: url, result: {
            cached in
            XCTAssertTrue(cached)
            expCachedCorrectly.fulfill()
        })
        
        wait(for: [expCachedCorrectly], timeout: 1)
        
        let expRetrieved = expectation(description: "retrieved image from cache")
        
        
        
        mockRamCache .getImageFor(url: url, result: {
            retrieved in
            XCTAssertNotNil(retrieved)
            XCTAssertEqual(retrieved!.pngData(), testImage.pngData())
            expRetrieved.fulfill()
        })
       
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    
    
    
    
    func testStorePolicy() {
        let normalUrl = "testUrl"
        let amazonUrl =  getTempAmazonUrlfrom(url: "amazonTempUrl")
        
        testStorePolicyFor(url: normalUrl)
        testStorePolicyFor(url: amazonUrl)
    }
    
    func testStorePolicyFor(url:String) {
        let testImage = testImage1
        
        let mockRamCache = RamCacheBuilder()
            .with(imageSet: SyncedAccessHashableCollection<ImageUrlWrapper>(array: [ImageUrlWrapper(url: url, image: testImage)]))
            .mock(storePolicy: .skip, queryPolicy: .returnNil)
        
        let expFinishedTest = expectation(description: "finished")
        
        mockRamCache.cache(image: testImage, url: url, result: {
            cacheResult in
            XCTAssertFalse(cacheResult)
            
            mockRamCache.getImageFor(url: url, result: {
                cachedImage in
                XCTAssertNil(cachedImage)
                
                mockRamCache.changeStore(Policy: .store)
                mockRamCache.cache(image: testImage, url: url, result: {
                    secondcacheResult in
                    XCTAssertTrue(secondcacheResult)
                    
                    mockRamCache.changeQuery(Policy: .checkInSet)
                    mockRamCache.getImageFor(url: url, result: {
                        secondCachedImage in
                        XCTAssertNotNil(secondCachedImage)
                        expFinishedTest.fulfill()
                    })
                })
            })
        })
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    
    
    func testReadPolicyPolicy() {
        let normalUrl = "testUrl"
        let amazonUrl =  getTempAmazonUrlfrom(url: "amazonTempUrl")
        
        testStorePolicyFor(url: normalUrl)
        testStorePolicyFor(url: amazonUrl)
    }
    
    func testReadPolicyFor(url:String) {
        let testImage = testImage1
        
        
        
        let mockRamCache = RamCacheBuilder()
            .with(imageSet: SyncedAccessHashableCollection<ImageUrlWrapper>(array: [ImageUrlWrapper(url: url, image: testImage)]))
            .mock(storePolicy: .skip, queryPolicy: .returnNil)
        
        let expFinishedTest = expectation(description: "finished")
        
        mockRamCache.getImageFor(url: url, result: {
            firstQueryImage in
            XCTAssertNil(firstQueryImage)
            
            mockRamCache.changeQuery(Policy: .checkInSet)
            
            mockRamCache.getImageFor(url: url, result: {
                secondQueryImage in
                XCTAssertNotNil(secondQueryImage)
                XCTAssertEqual(secondQueryImage!.pngData(), testImage.pngData())
                expFinishedTest.fulfill()
            })
            
        })
        
        wait(for: [expFinishedTest], timeout: 1)
      }
    
    
    
    
    
    
    
    
}
