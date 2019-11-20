//
//  FileSystemImageCacheTests.swift
//  RedPandaTests
//
//  Created by Omar Hassan  on 2/12/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest

@testable import ImageCollectionLoader

class DiskCacheFileSystemTests: XCTestCase {
    
    
    let testImage = testImage1
    
    let tempDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("tempDirectoryForTestingFileSystemImageCache")
    
    
    
    
    
    
    /**
     - this method is called before each test to create a temp directory for this test
     */
    func createTempDirectory() -> Void {
        do{
            try FileManager.default.createDirectory(atPath: tempDirectory.path, withIntermediateDirectories: true, attributes: nil)
            //print("created FIle Successfully")
            
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
    }
   
    
    /**
     - this function is called after each test to dlete the temp directory that was created for this test
     */
     func deleteTempDirectory() {
        do{
            try FileManager.default.removeItem(at: tempDirectory)
            //print("removed FIle Successfully")
        }catch let error as NSError {
            NSLog("Unable to delete directory \(error.debugDescription)")
        }
    }
    
    
    /// verify that the image is avaliable
    func fileSystemContainsUrlForImage(fileSystemCache:DiskCacheFileSystemProtocol,url:String,expectedImage:UIImage,expectationToFullfill:XCTestExpectation) -> Void {
       fileSystemCache.readFromFile(url: url, completion: {
            resultImage in
            XCTAssertNotNil(resultImage!)
            expectationToFullfill.fulfill()
        })
    
    }
    
    /// verify that the image is not in the file
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
        
        createTempDirectory()
        let fileSystemCache = DiskCacheFileSystemBuilder().concreteForTestingWithDifferentDirectory(directory:tempDirectory)
        
        
        
        let readFromFileExp = expectation(description: "read data from file successfully")
        
        
        fileSystemDoesnotContaintUrl(fileSystemCache: fileSystemCache, url: url, expectationToFullfill: readFromFileExp)
      
        waitForExpectations(timeout: 60, handler: nil)
        addTeardownBlock {
            self.deleteTempDirectory()
        }
    }
    
    
    
    /**
     - write to mock and verify that data was written by querying it again at the success handler of writing
     
     - cant use jpeg representation as comparison as with transformation to and from data some data is lost
     so instead use currentDate added to Url to make sure the url is different everyTime
     */
    func testWirteAndReadFromFile() -> Void {
        
        let currentDate = Date().timeIntervalSince1970
        let currentDateText = "\(currentDate)"
        let url = "wtiteReadUrl" + currentDateText
        
        createTempDirectory()
        let fileSystemCache = DiskCacheFileSystemBuilder().concreteForTestingWithDifferentDirectory(directory:tempDirectory)
        
        
        let writeToFileExp      = expectation(description: "successfully wrote to file")
        let readFromFileExp     = expectation(description: "read data from file successfully")
        let cleanUpExp          = expectation(description: "clean up saved data after test")
        let cleanUpReadExp      = expectation(description: "verify data is deleted by querying it")
        
        /// write to file and verify success
        fileSystemCache.writeToFile(image: testImage, url: url, completion: {
            result in
            XCTAssertEqual(result, true)
            writeToFileExp.fulfill()
       })
       
        wait(for: [writeToFileExp], timeout: 10)
        
        /// read from file to verify write
        fileSystemCache.readFromFile(url: url, completion: {
            cachedImage in
            XCTAssertNotNil(cachedImage)
            //XCTAssertNotNil(XCTAssertEqual(UIImageJPEGRepresentation(cachedImage!, 1.0), UIImageJPEGRepresentation(self.testImage, 1.0))
            readFromFileExp.fulfill()
        })
        wait(for: [readFromFileExp], timeout: 10)
        
        // delete image from file
        fileSystemCache.deleteFromFile(url: url, completion: {
            deleteResult in
            XCTAssertEqual(deleteResult, true)
            cleanUpExp.fulfill()
            
            // verify clean up by qurying the url and getting nil
            self.fileSystemDoesnotContaintUrl(fileSystemCache: fileSystemCache, url: url, expectationToFullfill: cleanUpReadExp)
            
        })
        
        waitForExpectations(timeout: 60, handler: nil)
        addTeardownBlock {
            self.deleteTempDirectory()
        }
        
    }
    
    
    
    /**
     - cant use jpeg representation as comparison as with transformation to and from data some data is lost
     so instead use currentDate added to Url to make sure the url is different everyTime
     
     */
    func testWriteReadDeleteFromFile() {
        let currentDate = Date().timeIntervalSince1970
        let currentDateText = "\(currentDate)"
        let url = "WriteReadDeleteUrl" + currentDateText
        
        createTempDirectory()
        let fileSystemCache = DiskCacheFileSystemBuilder().concreteForTestingWithDifferentDirectory(directory:tempDirectory)
        
        
        let writeToFileExp      = expectation(description: "successfully wrote to file")
        let readFromFileExp     = expectation(description: "read data from file successfully")
        let deleteFromFileExp   = expectation(description: "delete data from file successfully")
        let verifyDeleteExp     = expectation(description: "verify data was deleted successfully")
        
        // write to file
        fileSystemCache.writeToFile(image: testImage, url: url, completion: {
            result in
            XCTAssertEqual(result, true)
            writeToFileExp.fulfill()
        })
        
        wait(for: [writeToFileExp], timeout: 10)
        
        //verify writing by reading wrote data
        fileSystemCache.readFromFile(url: url, completion: {
            cachedImage in
            XCTAssertNotNil(cachedImage)
            readFromFileExp.fulfill()
       })
       
        wait(for: [readFromFileExp], timeout: 10)
        
        
        // delete from file
        fileSystemCache.deleteFromFile(url: url, completion: {
            deleteResult in
            
            XCTAssertEqual(deleteResult, true)
            deleteFromFileExp.fulfill()
            
            // verify delete by quering deleted data
            self.fileSystemDoesnotContaintUrl(fileSystemCache: fileSystemCache, url: url, expectationToFullfill: verifyDeleteExp)
        })
        
        waitForExpectations(timeout: 60, handler: nil)
        addTeardownBlock {
            self.deleteTempDirectory()
        }
    }
    
    
    /**
     - test adding data then deleteing it and verifying by querying deleted data
     - using same image has no conflict , the mock Set is hashed by URL only
     */
    func testDeleteAll() {
        let url1 = "testUrl--1"
        let url2 = "testUrl--2"
        
        createTempDirectory()
        let fileSystemCache = DiskCacheFileSystemBuilder().concreteForTestingWithDifferentDirectory(directory:tempDirectory)
        
        
        let firstWriteResultExp         = expectation(description: "successfully wrote first url & imaged")
        let secondtWriteResultExp       = expectation(description: "successfully wrote second url & imaged")
        
        
        let verifyFirstUrlDeletedExp    = expectation(description: "verify first url & image were deleted")
        let verifySecondUrlDeletedExp   = expectation(description: "verify second url & image were deleted")
        
        
        // write first Url & image to file
        fileSystemCache.writeToFile(image: testImage, url: url1, completion: {
            firstWriteResult in
            XCTAssertEqual(firstWriteResult, true)
            firstWriteResultExp.fulfill()
            
          })
        
        wait(for: [firstWriteResultExp], timeout: 10)
        
        // write second Url & image to file
        fileSystemCache.writeToFile(image: self.testImage, url: url2, completion: {
            secondWriteResult in
            XCTAssertEqual(secondWriteResult, true)
            secondtWriteResultExp.fulfill()
         })
        
        wait(for: [secondtWriteResultExp], timeout: 10)
        
        
        // dlete all data
        let deleteAllResult = fileSystemCache.deleteAll()
        XCTAssertEqual(deleteAllResult, true)
        
        // verify first item deletion
        self.fileSystemDoesnotContaintUrl(fileSystemCache: fileSystemCache, url: url1, expectationToFullfill: verifyFirstUrlDeletedExp)
        
        // verify second item deletion
        self.fileSystemDoesnotContaintUrl(fileSystemCache: fileSystemCache, url: url2, expectationToFullfill: verifySecondUrlDeletedExp)
        
        waitForExpectations(timeout: 60, handler: nil)
        addTeardownBlock {
            self.deleteTempDirectory()
        }
    }
    
    
    func testDeleteUrlCollection() {
        let url1 = "testUrl--1"
        let url2 = "testUrl--2"
        let url3 = "testURl--3"
        
        let tempTestImage = testImage1
        createTempDirectory()
        let fileSystemCache = DiskCacheFileSystemBuilder().concreteForTestingWithDifferentDirectory(directory:tempDirectory)
        
        
        let firstWriteResultExp         = expectation(description: "successfully wrote first url & image")
        let secondtWriteResultExp       = expectation(description: "successfully wrote second url & image")
        let thirdWriteResultExp         = expectation(description: "successfully wrote third url & image")
        
        
        let firstDeleteResultExp        = expectation(description: "successfully deleted first url & image")
        let secondtDeleteResultExp      = expectation(description: "successfully deleted second url & image")
        let thirdPersistanceResultExp   = expectation(description: "third url still persists and its image")
        
    
        
        // write first Url & image to file
        fileSystemCache.writeToFile(image: tempTestImage, url: url1, completion: {
            firstWriteResult in
            XCTAssertEqual(firstWriteResult, true)
            firstWriteResultExp.fulfill()
        })
       
        wait(for: [firstWriteResultExp], timeout: 10)
        
        // write second Url & image to file
        fileSystemCache.writeToFile(image: tempTestImage, url: url2, completion: {
            secondWriteResult in
            XCTAssertEqual(secondWriteResult, true)
            secondtWriteResultExp.fulfill()
    	})
        
        wait(for: [secondtWriteResultExp], timeout: 10)
        
        
        fileSystemCache.writeToFile(image: tempTestImage, url: url3, completion: {
            secondWriteResult in
            XCTAssertEqual(secondWriteResult, true)
            thirdWriteResultExp.fulfill()
        })
        wait(for: [thirdWriteResultExp], timeout: 10)
        
        
        let urlsToDelete = [url1,url2]
        fileSystemCache.deleteFilesWith(urls: urlsToDelete, completion: {
            deleteResult in
            
            // verify first item deletion
            self.fileSystemDoesnotContaintUrl(fileSystemCache: fileSystemCache, url: url1, expectationToFullfill: firstDeleteResultExp)
            
            
            // verify second item deletion
            self.fileSystemDoesnotContaintUrl(fileSystemCache: fileSystemCache, url: url2, expectationToFullfill: secondtDeleteResultExp)
            
            self.fileSystemContainsUrlForImage(fileSystemCache: fileSystemCache, url: url3, expectedImage: tempTestImage, expectationToFullfill: thirdPersistanceResultExp)
            
            
        })
        
        waitForExpectations(timeout: 60, handler: nil)
        addTeardownBlock {
            self.deleteTempDirectory()
        }
    }
   
    
//    func testCOncurruntRead() {
//         createTempDirectory()
//        let queue = DispatchQueue.init(label: "temp", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .workItem, target: DispatchQueue.global(qos: .userInteractive))
//        let expFinished = expectation(description: "")
//        for m in 0...20 {
//
//            let urls = Array.init(0...1000)
//            let fileSystemCache = DiskCacheFileSystemBuilder().concreteForTestingWithDifferentDirectory(directory:tempDirectory)
//            for i in urls {
//                queue.async {
//                    fileSystemCache.readFromFile(url: "emp url \(i)", completion: {
//                        result in
//                        print("result = \(result)   \(i)  \(m)")
//
//
//                        (m == 20 && i == 1000) ? expFinished.fulfill() : ()
//                    })
//                }
//            }
//        }
//
//        waitForExpectations(timeout: 50, handler: nil)
//    }
}

