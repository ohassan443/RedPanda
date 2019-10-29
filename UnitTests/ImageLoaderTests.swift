//
//  ImageLoaderServerTests.swift
//  ZabatneeTests
//
//  Created by Omar Hassan  on 2/3/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest
@testable import ImageCollectionLoader

class ImageLoaderTests: XCTestCase {
    
    /**
     - this test downloads an actual image from the internet
     - if the internet is not connected the test will fail
     - if the image url is not valid then it should be replaced with a working one
    
     
     ###  loading steps
     1. check in ramCache   <- this test
     2. check in diskCache
     3. requestFromServer
     
     */
    func testGetValidImage() {
        // this is a static url , if not valid anyMore change it for this test
        
        
        let url = UITestsConstants.baseUrl + "testImage"
        let testImage = testImage1
        let server = LocallServer.getInstance { (params, callBack) in
            callBack(LocallServer.LocalServerCallBack(statusCode: .s200, headers: [], body: testImage1.pngData()))
        }
        
        
        let emptyDiskCache = DiskCacheImageBuilder().unResponseiveMock()
       
        let emptyRamCache = RamCacheImageBuilder().unResponsiveMock()
        
        let imageLoader  = ImageLoaderBuilder()
            .with(diskCache: emptyDiskCache)
            .with(ramCache: emptyRamCache)
            .customConcrete()
        
        let successExp = expectation(description: "calling image from placeholder server")
        
        imageLoader.getImageFrom(urlString: url, completion: {
            image in
            successExp.fulfill()
        }, fail: {
            failedUrl,error in
            XCTFail()
        })
        
        
        waitForExpectations(timeout: 20, handler: nil)
        addTeardownBlock {
            server.stop()
        }
    }
    
    
    
    
    /**
     test that an invalid url (wrong format) will return 'URLError.unsupportedURL' error
     */
    func testInvalidUrl() {
        
        let staticUrl = "invalidUrl"
        
        let emptyDiskCache = DiskCacheImageBuilder().unResponseiveMock()
      
        let unResponsiveRamCache = RamCacheImageBuilder().unResponsiveMock()
        
        let imageLoader  = ImageLoaderBuilder()
            .with(diskCache: emptyDiskCache)
            .with(ramCache: unResponsiveRamCache)
            .customConcrete()
        
        let failExp = expectation(description: "call should fail to load url due it being invalid ")
        
        imageLoader.getImageFrom(urlString: staticUrl, completion: {
            image in
            XCTFail()
        }, fail: {
            failedUrl,error in
            
            let nsError = error as NSError
            
            XCTAssertEqual(nsError.code,URLError.unsupportedURL.rawValue)
            failExp.fulfill()
        })
        
        
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    
    
    
    
    /**
     - this image url holds an invalid image (expired url) which returns
     "AccessDeniedRequest has expired2019-01-27T23:55:47Z2019-02-03T17:20:15Z5DBB0AA0D21EAF3BwBUewdfjhcTRsXIHeJfBzBgSc621baitxKWK04tqYS5y/AxFCHqvZNT4t8NAnO6gFbstNOAFEwk="
     and should be treated as a parsing error
     
     -  test the returned failedUrl in the completion block is equal to the requested url
     */
    func testFiledParsingResponse() {
        // this is a static url , if not valid anyMore change it for this test
     
     	let url = UITestsConstants.baseUrl
        
        let testImage = testImage1
        let server = LocallServer.getInstance { (params, callBack) in
            callBack(LocallServer.LocalServerCallBack(statusCode: .s200, headers: [], body: Data()))
        }
        
        
        let emptyDiskCache = DiskCacheImageBuilder().unResponseiveMock()
        
        let emptyRamCache = RamCacheImageBuilder().unResponsiveMock()
        
        let imageLoader  = ImageLoaderBuilder()
            .with(diskCache: emptyDiskCache)
            .with(ramCache: emptyRamCache)
            .customConcrete()
        
        
        let failExp = expectation(description: "call should fail to load image as the response is not an image - text in the case of the above url")
        
        imageLoader.getImageFrom(urlString: url, completion: {
            image in
            XCTFail()
        }, fail: {
            failedUrl,error in
            
            
            XCTAssertEqual(failedUrl, url)
            
            switch error {
            case imageLoadingError.imageParsingFailed :
                failExp.fulfill()
            default :
                XCTFail()
            }
        })
        waitForExpectations(timeout: 20, handler: nil)
        addTeardownBlock {
            server.stop()
        }
    }
    
    
    
    
    /**
     ###  loading steps
     1. check in ramCache    <- this test
     2. check in diskCache
     3. requestFromServer
     */
    func testLoadingFromRamCache() -> Void {
        let testImage =  testImage1
        let testUrl = "testUrl" // used invalid url to make sure that the image is never retreieved from server and wether it was retreived from cache or not
        

        let imageSet : Set<ImageUrlWrapper> = [ImageUrlWrapper(url: testUrl, image: testImage)]
        
        let emptyDiskCache = DiskCacheImageBuilder().unResponseiveMock()
       
        let ramCache = RamCacheImageBuilder()
            .with(imageSet: imageSet)
            .mock(storePolicy: .store, queryPolicy: .checkInSet)
        
        let imageLoader  = ImageLoaderBuilder()
            .with(diskCache: emptyDiskCache)
            .with(ramCache: ramCache)
            .customConcrete()
        
        
        let ramCachedImage = imageLoader.queryRamCacheFor(url: testUrl)
       
        XCTAssertNotNil(ramCachedImage)
        XCTAssertEqual(ramCachedImage!.pngData(), testImage.pngData())
    }
    
    /**
     ###  loading steps
     1. check in ramCache
     2. check in diskCache   <- this test
     3. requestFromServer
     
     
     -- added very small timeout to make sure the image was loaded from the cache and not from the network
     */
    func testLoadingFromDiskCache() -> Void {
        
        let testImage = testImage1
        let testUrl = "testUrl" // used invalid url to make sure that the image is never retreieved from server and wether it was retreived from cache or not
        
        
        let imageSet : Set<ImageUrlWrapper> = [ImageUrlWrapper(url: testUrl, image: testImage)]
        
        let diskCache = DiskCacheImageBuilder()
            .with(images: imageSet)
            .mock(storePolicy: .store, queryPolicy: .checkInSet)
        
        let emptyRamCache = RamCacheImageBuilder().unResponsiveMock()
        
        let imageLoader  = ImageLoaderBuilder()
            .with(diskCache: diskCache)
            .with(ramCache: emptyRamCache)
            .customConcrete()
        
        
        let exp = expectation(description: "loaded image successfullt from disk cache")
        
        
        imageLoader.getImageFrom(urlString: testUrl, completion: {
            diskCacheImage in
            XCTAssertEqual(testImage.pngData(), diskCacheImage.pngData())
            exp.fulfill()
            
        }, fail: {
            faildUrl,error in
            XCTFail("failed to load image from disk cache")
        })
         waitForExpectations(timeout: 0.05, handler: nil)
        
    }
    
    /**
     - images loaded from disk are cached into ram
     */
    func testDiskLoadedImagesAreCachedIntoRam() {
        let testImage = testImage1
        let testUrl = "testUrl" // used invalid url to make sure that the image is never retreieved from server and wether it was retreived from cache or not
        
        
        let imageSet : Set<ImageUrlWrapper> = [ImageUrlWrapper(url: testUrl, image: testImage)]
        
        let diskCache = DiskCacheImageBuilder()
            .with(images: imageSet)
            .mock(storePolicy: .store, queryPolicy: .checkInSet)
        
        // ram cache should allow retreive
        let initiallyEmptyRamCache = RamCacheImageBuilder()
            .with(imageSet: [])
            .mock(storePolicy: .store, queryPolicy: .checkInSet)
        
        let imageLoader  = ImageLoaderBuilder()
            .with(diskCache: diskCache)
            .with(ramCache: initiallyEmptyRamCache)
            .customConcrete()
        
        
        let diskCacheExp = expectation(description: "loaded image successfullt from disk cache")
        let ramCacheExp  = expectation(description: "image was loaded from disk cache into ram cache")
        
        imageLoader.getImageFrom(urlString: testUrl, completion: {
            diskCacheImage in
            XCTAssertEqual(testImage.pngData(), diskCacheImage.pngData())
            diskCacheExp.fulfill()
            
            
            //check for image in ramCache that was passed in empty
            let ramCachedImage = initiallyEmptyRamCache.getImageFor(url: testUrl)
            XCTAssertNotNil(ramCachedImage)
            XCTAssertEqual(ramCachedImage!.pngData(), testImage.pngData())
            
            ramCacheExp.fulfill()
            
            
        }, fail: {
            faildUrl,error in
            XCTFail("failed to load image from disk cache")
        })
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    
    
    
    
    
    
}

let testImage1 = UIImage(named: "testImage1", in: Bundle(for:ImageLoaderTests.self), compatibleWith: nil)!
