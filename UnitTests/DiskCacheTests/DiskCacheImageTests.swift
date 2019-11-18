//
//  CacheTests.swift
//  ZabatneeTests
//
//  Created by Omar Hassan  on 2/4/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest
@testable import ImageCollectionLoader
/**
 - this cache is persisted in ram  for testing
 - uses realm's memory identifier to create actual realm object but just in memory and is deleted later
 */
class DiskCacheTests: XCTestCase {
    
    let image = testImage1

    
    
    
    
    
    
    
    
    func verifyUrlIsIn(cache:DiskCacheImage,url:String,expectedImage:UIImage,expectationToFullFill:XCTestExpectation) -> Void {
        cache.getImageFor(url: url, completion: {
            resultImage in
            
            XCTAssertNotNil(resultImage)
            XCTAssertEqual(resultImage?.png(), expectedImage.png())
            expectationToFullFill.fulfill()
        })
    }
    
    func verifyUrlIsNotAvaliable(cache:DiskCacheImage,url:String,expectedImage:UIImage,expectationToFullFill:XCTestExpectation) -> Void {
        cache.getImageFor(url: url, completion: {
            resultImage in
            
            XCTAssertNil(resultImage)
            expectationToFullFill.fulfill()
        })
    }
    
    
    
    
    
    
    /**
     - test insert image & url into diskCache
     - test with normal urls
     - test with amazon urls
     
     */
    
    func testInsert() -> Void {
        let dateUrl = "\(Date().timeIntervalSince1970)"
        let url = dateUrl
        let amazonUrl = getTempAmazonUrlfrom(url: url)
        
        
        testInsertImage(url: url)
        testInsertImage(url: amazonUrl)
    }
   
    
    func testInsertImage(url:String) {
        
        
        
        let insertExp = expectation(description: "insertImage")
        let verifyExp = expectation(description: "verify by querying the cached image ")
    
        
        
        let mockFileSystemImageCache = DiskCacheFileSystemBuilder()
            .mock()
        
        let mockDataBase    =  DiskCacheDataBaseBuilder().concreteForTesting()
        
        let diskCache = DiskCacheBuilder().concreteForTesting(DisckCacheImageDatabase: mockDataBase, fileSystemImacheCache: mockFileSystemImageCache)
        
        
        // insert image into Cache
        diskCache.cache(image: image, url: url, completion: {
            insertResult in
            
            XCTAssertEqual(insertResult, true)
            insertExp.fulfill()
            self.verifyUrlIsIn(cache: diskCache, url: url, expectedImage: self.image, expectationToFullFill: verifyExp)
        })
        
        
        
        waitForExpectations(timeout: 20, handler: nil)
        addTeardownBlock {
            let _ =  mockDataBase.deleteDataBase()
        }
    }
    
    

    
   
    
    
    
    
    /**
     if dataBase doesnot have an image, a delete call will return false
     */
    func testdeleteUnAvaliableNormalUrl(){
        let dateUrl = "\(Date().timeIntervalSince1970)"
        let url = dateUrl
        let amazonUrl = getTempAmazonUrlfrom(url: url)
        
        
        testDeleteUnAvaliableImage(url: url)
        testDeleteUnAvaliableImage(url: amazonUrl)
    }
    
    
    
    func testDeleteUnAvaliableImage(url:String) {
        let mockFileSystemImageCache = DiskCacheFileSystemBuilder()
            .mock()
        
      
        
        let mockDataBase =  DiskCacheDataBaseBuilder().concreteForTesting()
        
        let diskCache = DiskCacheBuilder().concreteForTesting(DisckCacheImageDatabase: mockDataBase, fileSystemImacheCache: mockFileSystemImageCache)
        
        let deleteExp = expectation(description: "deleteUnAvaliableImage")
        
        
        diskCache.delete(url: url, completion: {
            deleteResult in
            XCTAssertEqual(deleteResult, false)
            deleteExp.fulfill()
        })
        waitForExpectations(timeout: 2 , handler: nil)
        addTeardownBlock {
            let _ =  mockDataBase.deleteDataBase()
        }
    }
    
    
    

    
    

    
    
    
    
    
    
    
    /**
     if image is on FileSystemCache but not in dataBase
     delte process will faill / return false
     */
    func testImageAvaliableOnlyOnFileSystem() {
        let dateUrl = "\(Date().timeIntervalSince1970)"
        let url = dateUrl
        let amazonUrl = getTempAmazonUrlfrom(url: url)
        
        
        testImageIsAvaliableOnlyOnFileSystem(url: url)
        testImageIsAvaliableOnlyOnFileSystem(url: getTempAmazonUrlfrom(url: url))
    }
    func testImageIsAvaliableOnlyOnFileSystem(url:String) {
        
        let deleteExp    = expectation(description: "deleteUnAvaliableImage")
        let readVerifyExp = expectation(description: "verify not deletion  by reading ")
        let imageWrapper = ImageUrlWrapper(url: url, image: image)
        
        let mockFileSystemImageCache = DiskCacheFileSystemBuilder()
            .with(images: SyncedAccessHashableCollection<ImageUrlWrapper>(array: [imageWrapper]))
            .mock()
        
        let mockDataBase =  DiskCacheDataBaseBuilder().concreteForTesting()
        
         let diskCache = DiskCacheBuilder().concreteForTesting(DisckCacheImageDatabase: mockDataBase, fileSystemImacheCache: mockFileSystemImageCache)
        
        diskCache.delete(url: url, completion: {
            deleteResult in
            XCTAssertEqual(deleteResult, false)
            deleteExp.fulfill()
        })
        wait(for: [deleteExp], timeout: 10)
        
        mockFileSystemImageCache.readFromFile(url: url, completion: {
            deletedImage in
            XCTAssertNotNil(deletedImage)
            XCTAssertEqual(deletedImage!.pngData(), self.image.pngData())
            readVerifyExp.fulfill()
        })
        
        waitForExpectations(timeout: 2 * 60, handler: nil)
        addTeardownBlock {
            let _ =  mockDataBase.deleteDataBase()
        }
    }
    
    
    
    
    
    
    

    
   
    
    /**
     test: for normal url
     - adding an image
     - checking for added image
     - delete said image
     - confirm deletion of said image
     */
    func testNormalUrlFullFunctionality() {
        let dateUrl = "\(Date().timeIntervalSince1970)"
        let url = dateUrl
        let amazonUrl = getTempAmazonUrlfrom(url: url)
        testFullFunctionalityfor(url: url)
        testFullFunctionalityfor(url: amazonUrl)
        
        
        
    }
    
    func testFullFunctionalityfor(url:String) {
        
        
        let mockFileSystemImageCache = DiskCacheFileSystemBuilder()
            .mock()
        
        let mockDataBase =  DiskCacheDataBaseBuilder().concreteForTesting()
        
        let diskCache = DiskCacheBuilder().concreteForTesting(DisckCacheImageDatabase: mockDataBase, fileSystemImacheCache: mockFileSystemImageCache)
        
        guard let fileSystemUrl = PersistentUrl(url: url).getFileSystemName() else {
            XCTFail()
            return
        }
        
        let dataBaseInsertExp       = expectation(description: "dataBaseInsertImage")
        let dataBaseCheckExp        = expectation(description: "dataBaseCheckForImage")
        let dataBaseDeleteExp       = expectation(description: "dataBaseDeleteImage")
        let dataBaseVerifyDelete    = expectation(description: "dataBaseVerifyDeleteImage")
        
        
        let fileSystemCheckExp        = expectation(description: "fileSystemCheckForImage")
        let fileSystemVerifyDelete    = expectation(description: "fileSystemVerifyDeleteImage")
        
        
        
        // insert image into cache
        diskCache.cache(image: image, url: url, completion: {
            
            insertResult in
            XCTAssertEqual(insertResult, true)
            dataBaseInsertExp.fulfill()
        })
        
        wait(for: [dataBaseInsertExp], timeout: 10)
        
        // verify it was written to fileSystem
        mockFileSystemImageCache.readFromFile(url: fileSystemUrl, completion: {
            
            fileSystemImage in
            guard let diskImage = fileSystemImage else {
                XCTFail()
                return
            }
            XCTAssertEqual(diskImage.pngData(), self.image.pngData())
            fileSystemCheckExp.fulfill()
        })
        
        
        
        
        // verify it is accessiable from Database
        diskCache.getImageFor(url: url, completion: {
            cachedImage in
            XCTAssertNotNil(cachedImage)
            guard let image = cachedImage else {
                XCTFail()
                return
            }
            XCTAssertEqual(cachedImage!.pngData(), image.pngData())
            dataBaseCheckExp.fulfill()
        })
        
        wait(for: [dataBaseCheckExp,fileSystemCheckExp], timeout: 10)
        
        
        //delete image from cache
        diskCache.delete(url: url, completion: {
            deleteResult in
            XCTAssertEqual(deleteResult, true)
            dataBaseDeleteExp.fulfill()
        })
        wait(for: [dataBaseDeleteExp], timeout: 10)
        
        //check for deletetion in dataBase
        diskCache.getImageFor(url: url, completion: {
            deletedImage in
            XCTAssertNil(deletedImage)
            dataBaseVerifyDelete.fulfill()
        })
        
        
        
        // check for deletion in fileSystem
        mockFileSystemImageCache.readFromFile(url: fileSystemUrl, completion: {
            deletedFileSystemImage in
            XCTAssertNil(deletedFileSystemImage)
            fileSystemVerifyDelete.fulfill()
        })
        
     
        
        
        
        
        waitForExpectations(timeout: 20, handler: nil)
        addTeardownBlock {
            let _ =  mockDataBase.deleteDataBase()
        }
        
        
    }
}

