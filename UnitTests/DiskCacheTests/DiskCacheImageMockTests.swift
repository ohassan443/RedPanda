//
//  CacheMockTests.swift
//  RedPandaTests
//
//  Created by Omar Hassan  on 2/4/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest
@testable import ImageCollectionLoader

/**
 -  This cache is just a Set of ImageUrlWrapper
 */
class DiskCacheMockTests: XCTestCase {
    
    let image = testImage1
    
    // use current date as url to avoid collisions
    
    
    
    
    
    func verifyUrlAndImageInCache(cache:DiskCacheProtocol,url:String,expectedImage:UIImage,expectationToFullFill:XCTestExpectation) -> Void {
        cache.getImageFor(url: url, completion: {
            resultImage in
            
            XCTAssertNotNil(resultImage!)
            XCTAssertEqual(resultImage!.pngData(), expectedImage.pngData())
            expectationToFullFill.fulfill()
        })
    }
    
    func cacheDoesNotContainUrl(cache:DiskCacheProtocol,url:String,expectedImage:UIImage,expectationToFullFill:XCTestExpectation) -> Void {
        cache.getImageFor(url: url, completion: {
            resultImage in
            
            XCTAssertNil(resultImage)
            expectationToFullFill.fulfill()
        })
    }
    
    
    func testInsertImage() {
        let dateUrl = "\(Date().timeIntervalSince1970)"
        let url = dateUrl
        
        
        let mockDiskCache = DiskCacheBuilder().mock(storePolicy: .store, queryPolicy: .checkInSet)
        
        
        
        let insertExp       = expectation(description: "insertImage")
        let verifyInsertExp = expectation(description: "verify insert")
        
        // insert image into Cache
        mockDiskCache.cache(image: image, url: url, completion: {
            insertResult in
            
            XCTAssertEqual(insertResult, true)
            self.verifyUrlAndImageInCache(cache: mockDiskCache, url: url, expectedImage: self.image, expectationToFullFill: verifyInsertExp)
            insertExp.fulfill()
        })
        
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    
    /**
     check for deleting and url that is not cached
     */
    func testDeleteUnAvaliableImage() {
        let dateUrl = "\(Date().timeIntervalSince1970)"
        let url = dateUrl
        
        let mockDiskCache = DiskCacheBuilder().mock(storePolicy: .store, queryPolicy: .checkInSet)
        
        
        let verifyEmptyCache = expectation(description: "verify that deleted return true if url is not included")
        let deleteExp           = expectation(description: "deleteUnAvaliableImage")
        let verifyDeleteExp     = expectation(description: "verify deleting the image")
        
        cacheDoesNotContainUrl(cache: mockDiskCache, url: url, expectedImage: image, expectationToFullFill: verifyEmptyCache)
        
        mockDiskCache.delete(url: url, completion: {
            deleteResult in
            XCTAssertEqual(deleteResult, false)
            self.cacheDoesNotContainUrl(cache: mockDiskCache, url: url, expectedImage: self.image, expectationToFullFill: verifyDeleteExp)
            deleteExp.fulfill()
        })
        
        
        
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    
    func testStorePolicy() {
        let normalUrl = "testUrl"
        let amazonUrl =  getTempAmazonUrlfrom(url: "amazonTempUrl")
        
        testStorePolicyFor(url: normalUrl)
        testStorePolicyFor(url: amazonUrl)
    }
    
    func testStorePolicyFor(url:String) {
        let testImage = testImage1
        
        
        
        let mockDiskCache = DiskCacheBuilder().mock(storePolicy: .skip, queryPolicy: .checkInSet)
        
        
        let skipsCachingExp = expectation(description: "cache does not cache ")
        let verifySkippingCachingExp = expectation(description: "query for image that caching was skipped")
        
        let cacheExp = expectation(description: "cache should accept images and urls after changing policy")
        let verifyCaching = expectation(description: "verify caching the image ")
        
        mockDiskCache.cache(image: image, url: url, completion: {
            result in
            XCTAssertEqual(result, false)
            skipsCachingExp.fulfill()
        })
        
        wait(for: [skipsCachingExp], timeout: 10)
        
        
        mockDiskCache.getImageFor(url: url, completion: {
            cachedImage in
            XCTAssertEqual(cachedImage, nil)
            verifySkippingCachingExp.fulfill()
        })
        
        wait(for: [verifySkippingCachingExp], timeout: 10)
        
        
        mockDiskCache.changeStore(Policy: .store)
        
        mockDiskCache.cache(image: image, url: url, completion: {
            secondcacheResult in
            XCTAssertEqual(secondcacheResult, true)
            cacheExp.fulfill()
        })
        
        wait(for: [cacheExp], timeout: 10)
        
        mockDiskCache.getImageFor(url: url, completion: {
            secondCachedImage in
            XCTAssertNotNil(secondCachedImage)
            XCTAssertEqual(secondCachedImage!.png(), testImage.png())
            verifyCaching.fulfill()
        })
        
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    
    
    
    func testReadPolicyPolicy() {
        let normalUrl = "testUrl"
        let amazonUrl =  getTempAmazonUrlfrom(url: "amazonTempUrl")
        
        testStorePolicyFor(url: normalUrl)
        testStorePolicyFor(url: amazonUrl)
    }
    
    func testReadPolicyFor(url:String) {
        let testImage = testImage1
        
        let imageSet = SyncedAccessHashableCollection<ImageUrlWrapper>(array: [ImageUrlWrapper(url: url, image: testImage)])
        
     
        let mockDiskCache = DiskCacheBuilder()
            .with(images: imageSet)
            .mock(storePolicy: .skip, queryPolicy: .returnNil)
       
        
        let imageNotAvaliableExp = expectation(description: "image not avaliable because of policy ")
        let policyChangeAvaliableExp = expectation(description: "image is avaliable after changing expectation")
        
        mockDiskCache.getImageFor(url: url, completion: {
            nilImage in
            XCTAssertNil(nilImage)
            imageNotAvaliableExp.fulfill()
        })
        
        wait(for: [imageNotAvaliableExp], timeout: 10)
        mockDiskCache.changeQuery(Policy: .checkInSet)
        
        mockDiskCache.getImageFor(url: url, completion: {
            cachedImage in
            XCTAssertNotNil(cachedImage!)
            XCTAssertEqual(cachedImage!.png(),testImage.png())
            policyChangeAvaliableExp.fulfill()
        })
        
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    
    
    func testDeletingAll() {
        let url1 = "testURL--1"
        let url2 = "testURL--2"
        let url3 = "testURL--3"
        
        
        let mockDiskCache = DiskCacheBuilder().mock(storePolicy: .store, queryPolicy: .checkInSet)
        
        
        
        
        let verifyFirstInsertExp    = expectation(description: "verify insert 1 ")
        let verifySecondInsertExp   = expectation(description: "verify insert 2 ")
        let verifyThirdInsertExp    = expectation(description: "verify insert  3")
        
        
        let verifyDeletedFirstExp   = expectation(description: "verify deleteing 1")
        let verifyDelectedSecondExp = expectation(description: "verify deleteing 2")
        let verifyDeletedThidExp    = expectation(description: "verify deleteing 3")
        
        
        let deletedAllExp          = expectation(description: "all items were deleted")
        // insert image into Cache
        mockDiskCache.cache(image: image, url: url1, completion: {
            firstInsert in
            
            XCTAssertEqual(firstInsert, true)
            self.verifyUrlAndImageInCache(cache: mockDiskCache, url: url1, expectedImage: self.image, expectationToFullFill: verifyFirstInsertExp)
        })
        
        
        wait(for: [verifyFirstInsertExp], timeout: 10)
        
        mockDiskCache.cache(image: image, url: url2, completion: {
            secondInsert in
            
            XCTAssertEqual(secondInsert, true)
            self.verifyUrlAndImageInCache(cache: mockDiskCache, url: url2, expectedImage: self.image, expectationToFullFill: verifySecondInsertExp)
        })
        
        
        wait(for: [verifySecondInsertExp], timeout: 10)
        
        mockDiskCache.cache(image: image, url: url3, completion: {
            thirdInsert in
            
            XCTAssertEqual(thirdInsert, true)
            self.verifyUrlAndImageInCache(cache: mockDiskCache, url: url3, expectedImage: self.image, expectationToFullFill: verifyThirdInsertExp)
        })
        
        wait(for: [verifyThirdInsertExp], timeout: 10)
        
        
        let deleteResult = mockDiskCache.deleteAll()
        XCTAssertEqual(deleteResult, true)
        
        
        cacheDoesNotContainUrl(cache: mockDiskCache, url: url1, expectedImage: image, expectationToFullFill: verifyDeletedFirstExp)
        cacheDoesNotContainUrl(cache: mockDiskCache, url: url2, expectedImage: image, expectationToFullFill: verifyDelectedSecondExp)
        cacheDoesNotContainUrl(cache: mockDiskCache, url: url3, expectedImage: image, expectationToFullFill: verifyDeletedThidExp)
        
        wait(for: [verifyDeletedFirstExp,verifyDelectedSecondExp,verifyDeletedThidExp], timeout: 10)
        
        deletedAllExp.fulfill()
        
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    
    
    
    
    
    /**
     update minDate before caching the third date and only the first two should be dleted
     */
    func testDeleteWithMinDate() {
        let url1 = "testURL--1"
        let url2 = "testURL--2"
        let url3 = "testURL--3"
        
        
        let mockDiskCache = DiskCacheBuilder().mock(storePolicy: .store, queryPolicy: .checkInSet)
        
        
        
        
        let verifyFirstInsertExp    = expectation(description: "verify insert 1 ")
        let verifySecondInsertExp   = expectation(description: "verify insert 2 ")
        let verifyThirdInsertExp    = expectation(description: "verify insert  3")
        
        
        let verifyDeletedFirstExp   = expectation(description: "verify deleteing 1")
        let verifyDelectedSecondExp = expectation(description: "verify deleteing 2")
        
        let verifyThirdInNotDeletedExp    = expectation(description: "verify deleteing 3")
        
        
        let deletedAllExp          = expectation(description: "all items were deleted")
        
        
        
        var minDate = Date()
        mockDiskCache.cache(image: image, url: url1, completion: {
            firstInsert in
            
            XCTAssertEqual(firstInsert, true)
            self.verifyUrlAndImageInCache(cache: mockDiskCache, url: url1, expectedImage: self.image, expectationToFullFill: verifyFirstInsertExp)
       })
       
        wait(for: [verifyFirstInsertExp], timeout: 10)
        
        mockDiskCache.cache(image: image, url: url2, completion: {
            secondInsert in
            
            XCTAssertEqual(secondInsert, true)
            self.verifyUrlAndImageInCache(cache: mockDiskCache, url: url2, expectedImage: self.image, expectationToFullFill: verifySecondInsertExp)
        })
        
        wait(for: [verifySecondInsertExp], timeout: 10)
        
        //set minDate
        minDate = Date()
        
        
        mockDiskCache.cache(image: image, url: url3, completion: {
            thirdInsert in
            
            XCTAssertEqual(thirdInsert, true)
            self.verifyUrlAndImageInCache(cache: mockDiskCache, url: url3, expectedImage: self.image, expectationToFullFill: verifyThirdInsertExp)
        })
        
        wait(for: [verifyThirdInsertExp], timeout: 10)
        
        mockDiskCache.deleteWith(minLastAccessDate: minDate, completion: {
            deletedSuccessfully in
            
            self.cacheDoesNotContainUrl(cache: mockDiskCache, url: url1, expectedImage: self.image, expectationToFullFill: verifyDeletedFirstExp)
            self.cacheDoesNotContainUrl(cache: mockDiskCache, url: url2, expectedImage: self.image, expectationToFullFill: verifyDelectedSecondExp)
            
            self.verifyUrlAndImageInCache(cache: mockDiskCache, url: url3, expectedImage: self.image, expectationToFullFill: verifyThirdInNotDeletedExp)
            
        })
        
        
        
        
        
        deletedAllExp.fulfill()
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    
    
    
    
    
    
    
    
    
}

extension UIImage{
    func png()-> Data?{
        let x = self.pngData()
        return x
    }
}
