//
//  FileSystemImageCacheMockTests.swift
//  RedPandaTests
//
//  Created by Omar Hassan  on 2/12/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest

@testable import ImageCollectionLoader

class DiskCacheFileSystemMockTests: XCTestCase {

    let testImage = testImage1
   
    
    
    
    
    
    func fileSystemContainsUrlForImage(fileSystemCache:DiskCacheFileSystemProtocol,url:String,expectedImage:UIImage,expectationToFullfill:XCTestExpectation) -> Void {
        
        
        fileSystemCache.readFromFile(url: url, completion: {
            resultImage in
            XCTAssertNotNil(resultImage!)
            XCTAssertEqual(resultImage!.pngData(), expectedImage.pngData())
            expectationToFullfill.fulfill()
        })
        
    }
    
    func fileSystemDoesnotContaintUrl(fileSystemCache:DiskCacheFileSystemProtocol,url:String,expectationToFullfill:XCTestExpectation) -> Void {
        
        
        fileSystemCache.readFromFile(url: url, completion: {
            deletedImage in
            XCTAssertNil(deletedImage)
            expectationToFullfill.fulfill()
        })
        
    }
    
    
    
    /**
     test reading certain data from an empty cache returns nil
     */
    func testReadingUnAvaliableData() {
        let url = "testUrl"
        
        
        let fileSystemCacheMock = DiskCacheFileSystemBuilder()
            .mock()
        
        
        
        let readFromFileExp = expectation(description: "read data from file successfully")
        
        
        fileSystemDoesnotContaintUrl(fileSystemCache: fileSystemCacheMock, url: url, expectationToFullfill: readFromFileExp)
       
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    
    
    /**
     write to mock and verify that data was written by querying it again at the success handler of writing
     */
    func testWirteAndReadFromFile() -> Void {
        
        let url = "testUrl"
        
        
        let fileSystemCacheMock = DiskCacheFileSystemBuilder()
            .mock()
        
        
        let writeToFileExp = expectation(description: "successfully wrote to file")
        let readFromFileExp = expectation(description: "read data from file successfully")
        
        
        
        fileSystemCacheMock.writeToFile(image: testImage, url: url, completion: {
            result in
            XCTAssertEqual(result, true)
            writeToFileExp.fulfill()
            
            
            self.fileSystemContainsUrlForImage(fileSystemCache: fileSystemCacheMock, url: url, expectedImage: self.testImage, expectationToFullfill: readFromFileExp)
            
        })
        
        waitForExpectations(timeout: 20, handler: nil)
        
    }
    
    
    
    func testWriteReadDeleteFromFile() {
        let url = "testUrl"
        
        
        let fileSystemCacheMock = DiskCacheFileSystemBuilder()
            .mock()
        
        
        let writeToFileExp      = expectation(description: "successfully wrote to file")
        let readFromFileExp     = expectation(description: "read data from file successfully")
        let deleteFromFileExp   = expectation(description: "delete data from file successfully")
        let verifyDeleteExp     = expectation(description: "verify data was deleted successfully")
        
        // write to file
        fileSystemCacheMock.writeToFile(image: testImage, url: url, completion: {
            result in
            XCTAssertEqual(result, true)
            writeToFileExp.fulfill()
        })
        
        wait(for: [writeToFileExp], timeout: 10)
        //verify writing by reading wrote data
        fileSystemCacheMock.readFromFile(url: url, completion: {
            cachedImage in
            XCTAssertNotNil(cachedImage)
            XCTAssertEqual(cachedImage!.pngData(), self.testImage.pngData())
            readFromFileExp.fulfill()
        })
        
        wait(for: [readFromFileExp], timeout: 10)
        
        
        // delete from file
        fileSystemCacheMock.deleteFromFile(url: url, completion: {
            deleteResult in
            
            XCTAssertEqual(deleteResult, true)
            deleteFromFileExp.fulfill()
            // verify delete by quering deleted data
            
        })
        wait(for: [deleteFromFileExp], timeout: 10)
        
        self.fileSystemDoesnotContaintUrl(fileSystemCache: fileSystemCacheMock, url: url, expectationToFullfill: verifyDeleteExp)
        
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    
    /**
     - test adding data then deleteing it and verifying by querying deleted data
     - using same image has no conflict , the mock Set is hashed by URL only
     */
    func testDeleteAll() {
        let url1 = "testUrl--1"
        let url2 = "testUrl--2"
        
        let fileSystemCacheMock = DiskCacheFileSystemBuilder()
            .mock()
        
        
        let firstWriteResultExp         = expectation(description: "successfully wrote first url & imaged")
        let secondtWriteResultExp       = expectation(description: "successfully wrote second url & imaged")
        
        
        let verifyFirstUrlDeletedExp    = expectation(description: "verify first url & image were deleted")
        let verifySecondUrlDeletedExp   = expectation(description: "verify second url & image were deleted")
        
        
        // write first Url & image to file
        fileSystemCacheMock.writeToFile(image: testImage, url: url1, completion: {
            firstWriteResult in
            XCTAssertEqual(firstWriteResult, true)
            firstWriteResultExp.fulfill()
        })
        wait(for: [firstWriteResultExp], timeout: 10)
        
        
        // write second Url & image to file
        fileSystemCacheMock.writeToFile(image: self.testImage, url: url2, completion: {
            secondWriteResult in
            XCTAssertEqual(secondWriteResult, true)
            secondtWriteResultExp.fulfill()
        })
        
        wait(for: [secondtWriteResultExp], timeout: 10)
        
        // dlete all data
        let deleteAllResult = fileSystemCacheMock.deleteAll()
        XCTAssertEqual(deleteAllResult, true)
        
        
        // verify first item deletion
        self.fileSystemDoesnotContaintUrl(fileSystemCache: fileSystemCacheMock, url: url1, expectationToFullfill: verifyFirstUrlDeletedExp)
        
        
        // verify second item deletion
        self.fileSystemDoesnotContaintUrl(fileSystemCache: fileSystemCacheMock, url: url2, expectationToFullfill: verifySecondUrlDeletedExp)
        
        
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    /// add three images to disk , delete first two and verify that they are deleted and vierfy that the third is not deleted
    func testDeleteUrlCollection() {
        let url1 = "testUrl--1"
        let url2 = "testUrl--2"
        let url3 = "testURl--3"
        
        let tempTestImage = testImage1
        
        let fileSystemCacheMock = DiskCacheFileSystemBuilder()
            .mock()
        
        
        let firstWriteResultExp         = expectation(description: "successfully wrote first url & image")
        let secondtWriteResultExp       = expectation(description: "successfully wrote second url & image")
        let thirdWriteResultExp         = expectation(description: "successfully wrote third url & image")
        
        
        let firstDeleteResultExp        = expectation(description: "successfully deleted first url & image")
        let secondtDeleteResultExp      = expectation(description: "successfully deleted second url & image")
        let thirdPersistanceResultExp   = expectation(description: "third url still persists and its image")
        
        
        
        // write first Url & image to file
        fileSystemCacheMock.writeToFile(image: tempTestImage, url: url1, completion: {
            firstWriteResult in
            XCTAssertEqual(firstWriteResult, true)
            firstWriteResultExp.fulfill()
        })
        
        wait(for: [firstWriteResultExp], timeout: 10)
        
        // write second Url & image to file
        fileSystemCacheMock.writeToFile(image: tempTestImage, url: url2, completion: {
            secondWriteResult in
            XCTAssertEqual(secondWriteResult, true)
            secondtWriteResultExp.fulfill()
        })
        
        wait(for: [secondtWriteResultExp], timeout: 10)
        
        
        /// write third url and image to file
        fileSystemCacheMock.writeToFile(image: tempTestImage, url: url3, completion: {
            secondWriteResult in
            XCTAssertEqual(secondWriteResult, true)
            thirdWriteResultExp.fulfill()
       })
      
        wait(for: [thirdWriteResultExp], timeout: 10)
        
        /// delete first and second images and verify that the third is not deleted
        let urlsToDelete = [url1,url2]
        fileSystemCacheMock.deleteFilesWith(urls: urlsToDelete, completion: {
            deleteResult in
            
            // verify first item deletion
            self.fileSystemDoesnotContaintUrl(fileSystemCache: fileSystemCacheMock, url: url1, expectationToFullfill: firstDeleteResultExp)
            
            
            // verify second item deletion
            self.fileSystemDoesnotContaintUrl(fileSystemCache: fileSystemCacheMock, url: url2, expectationToFullfill: secondtDeleteResultExp)
            
            /// verify third item not deleted
            self.fileSystemContainsUrlForImage(fileSystemCache: fileSystemCacheMock, url: url3, expectedImage: tempTestImage, expectationToFullfill: thirdPersistanceResultExp)
            
            
        })
        waitForExpectations(timeout: 60, handler: nil)
        
    }
    
    
    
}
