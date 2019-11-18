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
    
 
    func testLoadImageFromServer() {
        
        /// create local server and stup image to the response
        let path = "testImage"
        let url = UITestsConstants.baseUrl + path
        let testImage = testImage1
               let expCalledLocalServer         = expectation(description: " image loader did call local server   ")
        let urlSessionMock = UrlSessionWrapperBuilder().mock(placeHolderCallBack: {
            arguments in
            
            arguments.callBack(testImage.png()!,nil,nil)
            
            XCTAssertTrue(  arguments.url == url)
            expCalledLocalServer.fulfill()
        })
        
        /// create ram and disk caches that always return nil
        let emptyDiskCache = DiskCacheBuilder().unResponseiveMock()
        let emptyRamCache = RamCacheBuilder().unResponsiveMock()
        
        /// create image loader
        let imageLoader  = ImageLoaderBuilder()
            .with(diskCache: emptyDiskCache)
            .with(ramCache: emptyRamCache)
            .with(urlSession: urlSessionMock)
            .customConcrete()
        
        let expLoadedImageSuccessfully   = expectation(description: " calling image from placeholder server")
 
        
        /// request Image and verify the loaded Image
        imageLoader.getImageFrom(urlString: url, completion: {
            image in
            expLoadedImageSuccessfully.fulfill()
        }, fail: {
            failedUrl,error in
            XCTFail()
        })
        
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    
    
    
    /**
     test that an invalid url (wrong format) will return 'URLError.unsupportedURL' error
     */
    func testInvalidUrl() {
        
        /// create invalid format url , ram and disk caches that always return nil
        let staticUrl = "invalidUrl"
        let emptyDiskCache = DiskCacheBuilder().unResponseiveMock()
        let unResponsiveRamCache = RamCacheBuilder().unResponsiveMock()
        
        
        let imageLoader  = ImageLoaderBuilder()
            .with(diskCache: emptyDiskCache)
            .with(ramCache: unResponsiveRamCache)
            .with(urlSession: UrlSessionWrapperBuilder().concrete())
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
        
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    
    
    
    
    /**
     -  test the returned failedUrl in the completion block is equal to the requested url
     */
    func testFiledParsingResponse() {
     
     	let url = UITestsConstants.baseUrl
        
        let testImage = testImage1
        
        var dataToReturnInServer : Data? = Data()
        
       
       
        
        let emptyDiskCache  = DiskCacheBuilder().unResponseiveMock()
        
        let emptyRamCache   = RamCacheBuilder().unResponsiveMock()
        let urlSessionMock  = UrlSessionWrapperBuilder().mock(placeHolderCallBack: {
            arguments in
            arguments.callBack(dataToReturnInServer,nil,nil)
        })
        
        
        let imageLoader  = ImageLoaderBuilder()
            .with(diskCache: emptyDiskCache)
            .with(ramCache: emptyRamCache)
            .with(urlSession:  urlSessionMock )
            .customConcrete()
        
        
        let expFailedDuToParsingImage = expectation(description: "call should fail to load image as the response is not parsable to an image")
        
        
        imageLoader.getImageFrom(urlString: url, completion: {
            image in
            XCTFail()
        }, fail: {
            failedUrl,error in
            
            
            XCTAssertEqual(failedUrl, url)
            
            switch error {
            case imageLoadingError.imageParsingFailed :
                expFailedDuToParsingImage.fulfill()
            default :
                XCTFail()
            }
        })
        
        wait(for: [expFailedDuToParsingImage], timeout: 2)
         let expFailedDueToNilData = expectation(description: "call should fail to load image as the response is nil data")
        dataToReturnInServer = nil
        
        imageLoader.getImageFrom(urlString: url, completion: {
                   image in
                   XCTFail()
               }, fail: {
                   failedUrl,error in
                   
                   
                   XCTAssertEqual(failedUrl, url)
                   
                   switch error {
                   case imageLoadingError.nilData :
                       expFailedDueToNilData.fulfill()
                   default :
                       XCTFail()
                   }
               })
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    
    
    
   
    func testLoadImageFromRamCache() -> Void {
        /// used invalid url to make sure that the image is never retreieved from server and wether it was retreived from cache or not
        let testImage =  testImage1
        let testUrl = "testUrl"
        
        /// create image list to pass to the ram cache and create disk cache that always returns nil
        let imageSet = SyncedAccessHashableCollection<ImageUrlWrapper>.init(array: [ImageUrlWrapper(url: testUrl, image: testImage)])
        let emptyDiskCache = DiskCacheBuilder().unResponseiveMock()
       
        /// create ram cache that will look in its collection and store in its collection
        let ramCache = RamCacheBuilder()
            .with(imageSet: imageSet)
            .mock(storePolicy: .store, queryPolicy: .checkInSet)
        
        let imageLoader  = ImageLoaderBuilder()
            .with(diskCache: emptyDiskCache)
            .with(ramCache: ramCache)
            .customConcrete()
        
        
        let expLoadedFromRam = expectation(description: "loaded image from ram ")
        let ramCachedImage = imageLoader.getImageFrom(urlString: testUrl, completion: {
            ramCachedImage in
            
            /// verify image was retrieved successfully
            XCTAssertNotNil(ramCachedImage)
            XCTAssertEqual(ramCachedImage.pngData(), testImage.pngData())
            expLoadedFromRam.fulfill()

        }, fail: {_,_ in
            XCTFail()
        })
       
        
        wait(for: [expLoadedFromRam], timeout: 1)
    }
    
 
    func testLoadingFromDiskCache() -> Void {
        
        // used invalid url to make sure that the image is never retreieved from server and wether it was retreived from cache or not
        let testImage = testImage1
        let testUrl = "testUrl"
        
        /// create image list to pass to the ram cache and create ram cache that always returns nil
        let imageSet = SyncedAccessHashableCollection<ImageUrlWrapper>(array: [ImageUrlWrapper(url: testUrl, image: testImage)])
        let emptyRamCache = RamCacheBuilder().unResponsiveMock()
        
        /// create disk cache that will look in its collection and store in its collection
        let diskCache = DiskCacheBuilder()
            .with(images: imageSet)
            .mock(storePolicy: .store, queryPolicy: .checkInSet)
        
        
        
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
         waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    /**
     - images loaded from disk are cached into ram
     */
    func testDiskLoadedImagesAreCachedIntoRam() {
        /// used invalid url to make sure that the image is never retreieved from server and wether it was retreived from cache or not
        let testImage = testImage1
        let testUrl = "testUrl"
        
        /// create responsive ram and disk cache mocks and itinalize the disk cache with an image
        let imageSet = SyncedAccessHashableCollection<ImageUrlWrapper>(array: [ImageUrlWrapper(url: testUrl, image: testImage)])
        
        let diskCache = DiskCacheBuilder()
            .with(images: imageSet)
            .mock(storePolicy: .store, queryPolicy: .checkInSet)
        
        // ram cache should allow retreive
        let initiallyEmptyRamCache = RamCacheBuilder()
            .with(imageSet: SyncedAccessHashableCollection<ImageUrlWrapper>.init(array: []))
            .mock(storePolicy: .store, queryPolicy: .checkInSet)
        
        let imageLoader  = ImageLoaderBuilder()
            .with(diskCache: diskCache)
            .with(ramCache: initiallyEmptyRamCache)
            .customConcrete()
        
        
        let diskCacheExp = expectation(description: "loaded image successfullt from disk cache")
        let ramCacheExp  = expectation(description: "image was loaded from disk cache into ram cache")
        
        
        
        /// load the image , should be returned from the disk cache and then look it up in the ram cache 
        imageLoader.getImageFrom(urlString: testUrl, completion: {
            diskCacheImage in
            XCTAssertEqual(testImage.pngData(), diskCacheImage.pngData())
            diskCacheExp.fulfill()
            
            
            //check for image in ramCache that was passed in empty
             initiallyEmptyRamCache.getImageFor(url: testUrl, result: {
            ramCachedImage in
                XCTAssertNotNil(ramCachedImage)
                XCTAssertEqual(ramCachedImage!.pngData(), testImage.pngData())
                
                ramCacheExp.fulfill()
            })
            
            
            
        }, fail: {
            faildUrl,error in
            XCTFail("failed to load image from disk cache")
        })
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    
    
    
    
    
    
}

let testImage1 = UIImage(named: "testImage1", in: Bundle(for:ImageLoaderTests.self), compatibleWith: nil)!
