//
//  ImageLoaderMockTests.swift
//  ZabatneeTests
//
//  Created by Omar Hassan  on 2/3/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest
@testable import Zabatnee

class ImageLoaderMockTests: XCTestCase {
    
    
    let image = UIImage(named: "testImage1")!
    
    /**
     - empty ram & disk caches and mock Loader (no internet)
     - should return image passed at initaliaztion of the mock
     */
    func testLoadingDirectImage() {
        let testUrl = "testUrl"
        
        let emptyDiskCache = DiskCacheImageBuilder().unResponseiveMock()
        
        let unresponsiveRamCache = RamCacheImageBuilder().unResponsiveMock()
        
        
        
        
        let imageLoader  = ImageLoaderBuilder()
            .with(diskCache: emptyDiskCache)
            .with(ramCache: unresponsiveRamCache)
            .loaderMock(response: .responseImage(image: image))
        
        
        let exp = expectation(description: "responded with image provided at initalization as response image ")
        imageLoader.getImageFrom(urlString: testUrl, completion: {
            directResponseImage in
            XCTAssertEqual(UIImagePNGRepresentation(self.image), UIImagePNGRepresentation(directResponseImage))
            exp.fulfill()
            
        }, fail: {
            faildUrl,error in
            XCTFail("failed to responded with image provided at initalization")
        })
        
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    
    
    
    
    
    // retreieve image from ram cache
    func testLoadingFromRamCache() {
        let testUrl = "testUrl" // used invalid url to make sure that the image is never retreieved from server and wether it was retreived from cache or not
        
        
        let imageSet : Set<ImageUrlWrapper> = [ImageUrlWrapper(url: testUrl, image: image)]
        
        let emptyDiskCache = DiskCacheImageBuilder().unResponseiveMock()
        
        let ramCache = RamCacheImageBuilder()
            .with(imageSet: imageSet)
            .mock(storePolicy: .store, queryPolicy: .checkInSet)
        
        
        
        
        let imageLoader  = ImageLoaderBuilder()
            .with(diskCache: emptyDiskCache)
            .with(ramCache: ramCache)
            .loaderMock(response: .ramCache)
        
        
        let exp = expectation(description: "loaded image successfullt from ram cache")
        imageLoader.getImageFrom(urlString: testUrl, completion: {
            ramCacheImage in
            XCTAssertEqual(UIImagePNGRepresentation(self.image), UIImagePNGRepresentation(ramCacheImage))
            exp.fulfill()
            
        }, fail: {
            faildUrl,error in
            XCTFail("failed to load image from ram cache")
        })
        
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    
    
    
    // retreieve image from disk cache
    func testLoadingFromDiskCache() -> Void {
        
        let testImage = UIImage(named: "testImage1")!
        let testUrl = "testUrl" // used invalid url to make sure that the image is never retreieved from server and wether it was retreived from cache or not
        
        
        let imageSet : Set<ImageUrlWrapper> = [ImageUrlWrapper(url: testUrl, image: testImage)]
        
        let diskCache = DiskCacheImageBuilder()
            .with(images: imageSet)
            .mock(storePolicy: .store, queryPolicy: .checkInSet)
        
        let emptyRamCache = RamCacheImageBuilder().unResponsiveMock()
        
        
        let imageLoader  = ImageLoaderBuilder()
            .with(diskCache: diskCache)
            .with(ramCache: emptyRamCache)
            .loaderMock(response: .diskCache)
        
        
        let exp = expectation(description: "loaded image successfullt from disk cache")
        imageLoader.getImageFrom(urlString: testUrl, completion: {
            diskCacheImage in
            XCTAssertEqual(UIImagePNGRepresentation(testImage), UIImagePNGRepresentation(diskCacheImage))
            exp.fulfill()
            
        }, fail: {
            faildUrl,error in
            XCTFail("failed to load image from disk cache")
        })
        waitForExpectations(timeout: 20, handler: nil)
        
    }
    
    
    /// validate target errors are thrown
    func testThrowingErrors() {
        let imageParsingFailed = imageLoadingError.imageParsingFailed
        let invalidResponse = imageLoadingError.invalidResponse
        let networkError = imageLoadingError.networkError
        
        testMockThrowingError(error: imageParsingFailed)
        testMockThrowingError(error: invalidResponse)
        testMockThrowingError(error: networkError)
        
        testMockThrowingError(error: URLError(URLError.unknown))
        
    }
    
    func testMockThrowingError(error:Error) -> Void {
        
        let testUrl = "dummy invalid Url"
        
        let emptyDiskCache = DiskCacheImageBuilder().unResponseiveMock()
        
        let emptyRamCache = RamCacheImageBuilder().unResponsiveMock()
        
        
        let imageLoader  = ImageLoaderBuilder()
            .with(diskCache: emptyDiskCache)
            .with(ramCache: emptyRamCache)
            .loaderMock(response: ImageLoaderMock.ReturnResponse.throwError(error: error))
        
        
        let exp = expectation(description: "verify mock throwing passed error at initialization")
        imageLoader.getImageFrom(urlString: testUrl, completion: {
            _ in
            XCTFail("failed to throw error")
            
        }, fail: {
            faildUrl,loadingError in
            
            
            let thrownErrorCode = (loadingError as NSError).code
            let targetErrorCode = (error as NSError).code
            
            XCTAssertEqual(thrownErrorCode, targetErrorCode)
            exp.fulfill()
        })
        waitForExpectations(timeout: 20, handler: nil)
        
    }
    
    
    
    /**
     - specifiying ram as response without initalizing the ram
     - should throw error
     */
    func testFailedLoadingFromRam() {
        
        let testUrl = "dummy invalid Url"
        
        let emptyDiskCache = DiskCacheImageBuilder().unResponseiveMock()
        
        let emptyRamCache = RamCacheImageBuilder().unResponsiveMock()
        
        
        let imageLoader  = ImageLoaderBuilder()
            .with(diskCache: emptyDiskCache)
            .with(ramCache: emptyRamCache)
            .loaderMock(response: .ramCache)
        
        
        let exp = expectation(description: "verify mock throwing error for empty ram cache")
        imageLoader.getImageFrom(urlString: testUrl, completion: {
            _ in
            XCTFail("failed to throw error")
            
        }, fail: {
            faildUrl,loadingError in
            
            let thrownErrorCode = (loadingError as NSError).code
            let targetErrorCode = ( ImageLoaderMock.MockError.mockImageUnAvaliable as NSError).code
            
            XCTAssertEqual(thrownErrorCode,targetErrorCode)
            
            exp.fulfill()
        })
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    
    
    
    
    /**
     - specifiying disk cache as response without initalizing the disk
     - should throw error
     */
    func testFailedLoadingFromDiskCache() {
        
        let testUrl = "dummy invalid Url"
        
        let emptyDiskCache = DiskCacheImageBuilder().unResponseiveMock()
        
        let emptyRamCache = RamCacheImageBuilder().unResponsiveMock()
        
        
        let imageLoader  = ImageLoaderBuilder()
            .with(diskCache: emptyDiskCache)
            .with(ramCache: emptyRamCache)
            .loaderMock(response: .diskCache)
        
        
        let exp = expectation(description: "verify mock throwing error for empty disk cache")
        imageLoader.getImageFrom(urlString: testUrl, completion: {
            _ in
            XCTFail("failed to throw error")
            
        }, fail: {
            faildUrl,loadingError in
            
            let thrownErrorCode = (loadingError as NSError).code
            let targetErrorCode = ( ImageLoaderMock.MockError.mockImageUnAvaliable as NSError).code
            
            XCTAssertEqual(thrownErrorCode,targetErrorCode)
            
            exp.fulfill()
        })
        waitForExpectations(timeout: 20, handler: nil)
    }
    
}

