//
//  DiskCacheImagesDatabaseTests.swift
//  ZabatneeTests
//
//  Created by Omar Hassan  on 2/14/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest
@testable import ImageCollectionLoader
class DIskCacheDataBaseTests: XCTestCase {

    /**
     let dateUrl = "\(Date().timeIntervalSince1970)"
     let url = dateUrl
     let amazonUrl = getTempAmazonUrlfrom(url: url)
     
     
     testInsertImage(url: url)
     testInsertImage(url: amazonUrl)
     */

    func testCacheAndRetrieve() {
        let dateUrl = "\(Date().timeIntervalSince1970)"
        let url = dateUrl
        let amazonUrl = getTempAmazonUrlfrom(url: url)
        
        
        testDataBaseGeneratesCorrectFileNamesFor(url: url)
        testDataBaseGeneratesCorrectFileNamesFor(url: amazonUrl)
    }
    /**
     - the hashing in database and in the test are made in the same run so the seed is that same
     - using a persistentImage getFileSystemName to retreieve from fileSystme will fail , file system urls must be retreieved from the database only
     */
    func testDataBaseGeneratesCorrectFileNamesFor(url:String) {
        let database = DiskCacheDataBaseBuilder().concreteForTesting()
        
        /// correct expected file name to match aganist
        let expectedFileSystemName              = PersistentUrl(url: url).getFileSystemName()
        
        
        /// expectations
        let expDataBaseReturnedCorrectFileName  = expectation(description: "after caching the image ")
        let expCacheSuccess                     = expectation(description: "obj was added to the database")
        
        /// cache the url to the database
        database.cache( url: url, completion: {
            success in
            XCTAssertEqual(success, true)
            expCacheSuccess.fulfill()
          
        })
        
        /// wait for caching success
        wait(for: [expCacheSuccess], timeout: 2)
        
        
        /// getthe file name that was saved for the url and match it aganist the expected url
        database.getFileSystemUrlFor(url: url, completion: {
            cachedFileSystemUrlString in
            XCTAssertNotNil(cachedFileSystemUrlString)
            XCTAssertEqual(cachedFileSystemUrlString, expectedFileSystemName)
            expDataBaseReturnedCorrectFileName.fulfill()
        })
        
        
        
        
        
        waitForExpectations(timeout: 2, handler: nil)
        addTeardownBlock {
            let _ =  database.deleteDataBase()
        }
    }
    
    
    
    
    
    
    
    func testDataBaseDateFiltering() -> Void {
        let dateUrl = "\(Date().timeIntervalSince1970)"
        let url = dateUrl
        let amazonUrl = getTempAmazonUrlfrom(url: url)
        
        
        testDataBaseDateFiltering(url: url)
        testDataBaseDateFiltering(url: amazonUrl)
    }
    /**
     
     */
    func testDataBaseDateFiltering(url:String) -> Void {
        
        let firstUrl =  "1" + url
        let secondUrl = "2" + url
        let thirdUrl =  "3" + url
        
        
        /// the name of the images on the disk file for each url 
        let firstFileSystemUrl  = PersistentUrl(url: firstUrl).getFileSystemName()!
        let secondFileSystemUrl = PersistentUrl(url: secondUrl).getFileSystemName()!
        let thirdFileSystemUrl  = PersistentUrl(url: thirdUrl).getFileSystemName()!
        
        
        let database                  = DiskCacheDataBaseBuilder().concreteForTesting()
        
        
        
        
        
        let expCachedFirstUrl       = expectation(description: "cached first  url successfully")
        let expCachedSecondUrl      = expectation(description: "cached second url successfully")
        let expCachedThirdUrl       = expectation(description: "cached third  url successfully")
        
        
        let expFinished = expectation(description: "verify that urls that were cached before the last set of min date will only be retreived in the date filter call later")
        
        /// cache first and second urls to the data base
        database.cache( url: firstUrl, completion: {
            firstCacheResult in
            XCTAssertEqual(firstCacheResult, true)
            expCachedFirstUrl.fulfill()
        })
        
        wait(for: [expCachedFirstUrl], timeout: 10)
        
        database.cache(url: secondUrl, completion: {
            secondCacheResult in
            XCTAssertEqual(secondCacheResult, true)
            expCachedSecondUrl.fulfill()
         })
        
        wait(for: [expCachedSecondUrl], timeout: 10)
        
        /// log the date before caching the third url and cache the third url
        let thirdUrlCacheDate = Date()
        
        database.cache(url: thirdUrl, completion: {
            thirdCacheResult in
            XCTAssertEqual(thirdCacheResult, true)
            expCachedThirdUrl.fulfill()
        })
        
        wait(for: [expCachedThirdUrl], timeout: 10)
        
        
        /// verify that asking for urls with minAccessDate equal to the date of caching the third url return only the first and second urls
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
            database.getUrlsWith(minlastAccessDate: thirdUrlCacheDate, completion: {
                fileSystemUrls in
                //print(url)
                XCTAssert(fileSystemUrls.contains(firstFileSystemUrl))
                XCTAssert(fileSystemUrls.contains(secondFileSystemUrl))
                
                XCTAssertFalse(fileSystemUrls.contains(thirdFileSystemUrl))
                expFinished.fulfill()
            })
        })
        
        waitForExpectations(timeout: 2, handler: nil)
        
        
        addTeardownBlock {
            let _ =  database.deleteDataBase()
        }
    }
}
