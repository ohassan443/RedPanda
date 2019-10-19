//
//  FileSystemImageCacheTests.swift
//  ZabatneeTests
//
//  Created by Omar Hassan  on 2/12/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest

@testable import Zabatnee

class FileSystemImageCacheTests: XCTestCase {
    
    
    let testImage = UIImage(named: "testImage1")!
    
    let tempDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("tempDirectoryForTestingFileSystemImageCache")
    
    
    
    
    
    
    /**
     - this method is called before each test
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
     - this function is called after each test
     */
     func deleteTempDirectory() {
        do{
            try FileManager.default.removeItem(at: tempDirectory)
            //print("removed FIle Successfully")
        }catch let error as NSError {
            NSLog("Unable to delete directory \(error.debugDescription)")
        }
    }
    
    
    
    func fileSystemContainsUrlForImage(fileSystemCache:FileSystemImageCacheObj,url:String,expectedImage:UIImage,expectationToFullfill:XCTestExpectation) -> Void {
        
        
        fileSystemCache.readFromFile(url: url, completion: {
            resultImage in
            XCTAssertNotNil(resultImage!)
            XCTAssertEqual(UIImagePNGRepresentation(resultImage!), UIImagePNGRepresentation(expectedImage))
            expectationToFullfill.fulfill()
        })
    
    }
    
    func fileSystemDoesnotContaintUrl(fileSystemCache:FileSystemImageCacheObj,url:String,expectationToFullfill:XCTestExpectation) -> Void {
        
        
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
        let fileSystemCache = FileSystemImageCacheBuilder().concreteForTestingWithDifferentDirectory(directory:tempDirectory)
        
        
        
        let readFromFileExp = expectation(description: "read data from file successfully")
        
        
        fileSystemDoesnotContaintUrl(fileSystemCache: fileSystemCache, url: url, expectationToFullfill: readFromFileExp)
      
        waitForExpectations(timeout: 60, handler: nil)
        deleteTempDirectory()
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
        let fileSystemCache = FileSystemImageCacheBuilder().concreteForTestingWithDifferentDirectory(directory:tempDirectory)
        
        
        let writeToFileExp      = expectation(description: "successfully wrote to file")
        let readFromFileExp     = expectation(description: "read data from file successfully")
        let cleanUpExp          = expectation(description: "clean up saved data after test")
        let cleanUpReadExp      = expectation(description: "verify data is deleted by querying it")
        
        
        fileSystemCache.writeToFile(image: testImage, url: url, completion: {
            result in
            XCTAssertEqual(result, true)
            writeToFileExp.fulfill()
            
            
            fileSystemCache.readFromFile(url: url, completion: {
                cachedImage in
                //XCTAssertNotNil(XCTAssertEqual(UIImageJPEGRepresentation(cachedImage!, 1.0), UIImageJPEGRepresentation(self.testImage, 1.0))
                readFromFileExp.fulfill()
                
                
                // clean up after test
                fileSystemCache.deleteFromFile(url: url, completion: {
                    deleteResult in
                    XCTAssertEqual(deleteResult, true)
                    cleanUpExp.fulfill()
                    
                    // verify clean up by qurying the url and getting nil
                    self.fileSystemDoesnotContaintUrl(fileSystemCache: fileSystemCache, url: url, expectationToFullfill: cleanUpReadExp)
                  
                })
            })
        })
        
        waitForExpectations(timeout: 60, handler: nil)
        deleteTempDirectory()
        
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
        let fileSystemCache = FileSystemImageCacheBuilder().concreteForTestingWithDifferentDirectory(directory:tempDirectory)
        
        
        let writeToFileExp      = expectation(description: "successfully wrote to file")
        let readFromFileExp     = expectation(description: "read data from file successfully")
        let deleteFromFileExp   = expectation(description: "delete data from file successfully")
        let verifyDeleteExp     = expectation(description: "verify data was deleted successfully")
        
        // write to file
        fileSystemCache.writeToFile(image: testImage, url: url, completion: {
            result in
            XCTAssertEqual(result, true)
            writeToFileExp.fulfill()
            
            
            
            //verify writing by reading wrote data
            fileSystemCache.readFromFile(url: url, completion: {
                cachedImage in
                XCTAssertNotNil(cachedImage)
                readFromFileExp.fulfill()
                
                
                // delete from file
                fileSystemCache.deleteFromFile(url: url, completion: {
                    deleteResult in
                    
                    XCTAssertEqual(deleteResult, true)
                    deleteFromFileExp.fulfill()
                    
                    
                    
                    // verify delete by quering deleted data
                    self.fileSystemDoesnotContaintUrl(fileSystemCache: fileSystemCache, url: url, expectationToFullfill: verifyDeleteExp)
                })
            })
            
        })
        
        waitForExpectations(timeout: 60, handler: nil)
        deleteTempDirectory()
    }
    
    
    /**
     - test adding data then deleteing it and verifying by querying deleted data
     - using same image has no conflict , the mock Set is hashed by URL only
     */
    func testDeleteAll() {
        let url1 = "testUrl--1"
        let url2 = "testUrl--2"
        
        createTempDirectory()
        let fileSystemCache = FileSystemImageCacheBuilder().concreteForTestingWithDifferentDirectory(directory:tempDirectory)
        
        
        let firstWriteResultExp         = expectation(description: "successfully wrote first url & imaged")
        let secondtWriteResultExp       = expectation(description: "successfully wrote second url & imaged")
        
        
        let verifyFirstUrlDeletedExp    = expectation(description: "verify first url & image were deleted")
        let verifySecondUrlDeletedExp   = expectation(description: "verify second url & image were deleted")
        
        
        // write first Url & image to file
        fileSystemCache.writeToFile(image: testImage, url: url1, completion: {
            firstWriteResult in
            XCTAssertEqual(firstWriteResult, true)
            firstWriteResultExp.fulfill()
            
            
            // write second Url & image to file
            fileSystemCache.writeToFile(image: self.testImage, url: url2, completion: {
                secondWriteResult in
                XCTAssertEqual(secondWriteResult, true)
                secondtWriteResultExp.fulfill()
                
                // dlete all data
                let deleteAllResult = fileSystemCache.deleteAll()
                XCTAssertEqual(deleteAllResult, true)
                
                
                
                
                // verify first item deletion
                self.fileSystemDoesnotContaintUrl(fileSystemCache: fileSystemCache, url: url1, expectationToFullfill: verifyFirstUrlDeletedExp)
                
                
                // verify second item deletion
                self.fileSystemDoesnotContaintUrl(fileSystemCache: fileSystemCache, url: url2, expectationToFullfill: verifySecondUrlDeletedExp)
                
                
                
            })
            
            
            
        })
        
        waitForExpectations(timeout: 60, handler: nil)
        deleteTempDirectory()
    }
    
    
    func testDeleteUrlCollection() {
        let url1 = "testUrl--1"
        let url2 = "testUrl--2"
        let url3 = "testURl--3"
        
        let tempTestImage = UIImage(named: "testImage1")!
        createTempDirectory()
        let fileSystemCache = FileSystemImageCacheBuilder().concreteForTestingWithDifferentDirectory(directory:tempDirectory)
        
        
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
            
            
            // write second Url & image to file
            fileSystemCache.writeToFile(image: tempTestImage, url: url2, completion: {
                secondWriteResult in
                XCTAssertEqual(secondWriteResult, true)
                secondtWriteResultExp.fulfill()
                
                
                fileSystemCache.writeToFile(image: tempTestImage, url: url3, completion: {
                    secondWriteResult in
                    XCTAssertEqual(secondWriteResult, true)
                    thirdWriteResultExp.fulfill()
                    
                    
                    let urlsToDelete = [url1,url2]
                    fileSystemCache.deleteFilesWith(urls: urlsToDelete, completion: {
                        deleteResult in
                        
                        // verify first item deletion
                        self.fileSystemDoesnotContaintUrl(fileSystemCache: fileSystemCache, url: url1, expectationToFullfill: firstDeleteResultExp)
                        
                        
                        // verify second item deletion
                        self.fileSystemDoesnotContaintUrl(fileSystemCache: fileSystemCache, url: url2, expectationToFullfill: secondtDeleteResultExp)
                        
                        self.fileSystemContainsUrlForImage(fileSystemCache: fileSystemCache, url: url3, expectedImage: tempTestImage, expectationToFullfill: thirdPersistanceResultExp)
                        
                        
                    })
                })
            })
            
            
            
        })
        
        waitForExpectations(timeout: 60, handler: nil)
        deleteTempDirectory()
    }
   
    
    
}

