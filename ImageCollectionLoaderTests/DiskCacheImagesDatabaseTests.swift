//
//  DiskCacheImagesDatabaseTests.swift
//  ZabatneeTests
//
//  Created by Omar Hassan  on 2/14/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest
@testable import Zabatnee
class DiskCacheImagesDatabaseTests: XCTestCase {

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
        
        
        testCacheAndRetrieve(url: url)
        testCacheAndRetrieve(url: amazonUrl)
    }
    /**
     - the hashing in database and in the test are made in the same run so the seed is that same
     - using a persistentImage getFileSystemName to retreieve from fileSystme will fail , file system urls must be retreieved from the database only
     */
    func testCacheAndRetrieve(url:String) {
        let database = DiskCacheImageDataBaseBuilder().concreteForTesting()
        
        
        let dataBaseObj = PersistentUrl(url: url)
        let expectedFileSystemName = dataBaseObj.getFileSystemName()
        
        
        
        let sameFileSystemName = expectation(description: "file systme generated from persistentImage should be equal to the one retreived from the database after caching the base url")
        
        database.cache( url: url, completion: {
            success in
            XCTAssertEqual(success, true)
            
            database.getFileSystemUrlFor(url: url, completion: {
                cachedFileSystemUrlString in
                XCTAssertNotNil(cachedFileSystemUrlString)
                XCTAssertEqual(cachedFileSystemUrlString, expectedFileSystemName)
                sameFileSystemName.fulfill()
            })
        })
        
        waitForExpectations(timeout: 20, handler: nil)
       let _ =  database.deleteDataBase()
    }
    
    
    
    
    
    
    
    func testGetUrlsBeforeCertain() -> Void {
        let dateUrl = "\(Date().timeIntervalSince1970)"
        let url = dateUrl
        let amazonUrl = getTempAmazonUrlfrom(url: url)
        
        
        testGetUrlsBeforeCertainDate(url: url)
        testGetUrlsBeforeCertainDate(url: amazonUrl)
    }
    /**
     
     */
    func testGetUrlsBeforeCertainDate(url:String) -> Void {
        
        let firstUrl =  "1" + url
        let secondUrl = "2" + url
        let thirdUrl = "3" + url
        
        
        let firstFileSystemUrl = PersistentUrl(url: firstUrl).getFileSystemName()!
        let secondFileSystemUrl = PersistentUrl(url: secondUrl).getFileSystemName()!
        let thirdFileSystemUrl = PersistentUrl(url: thirdUrl).getFileSystemName()!
        
        var minDate = Date()
        let database = DiskCacheImageDataBaseBuilder().concreteForTesting()
        
        
        
        
        
        let cachedFirstExp = expectation(description: "cached first successfully")
        let cachedSecondExp = expectation(description: "cached second successfully")
        let cachedThirdExp = expectation(description: "cached third successfully")
        
        
        let verifyUrlsBeforeDate = expectation(description: "verify that urls that was cached before the last set of min date will only be retreived in the date filter call later")
        
        database.cache( url: firstUrl, completion: {
            firstCacheResult in
            XCTAssertEqual(firstCacheResult, true)
            cachedFirstExp.fulfill()
            
            
            
            database.cache(url: secondUrl, completion: {
                secondCacheResult in
                XCTAssertEqual(secondCacheResult, true)
                cachedSecondExp.fulfill()
                
                
                
                
                
                // set minDate
                minDate = Date()
                
                database.cache(url: thirdUrl, completion: {
                    thirdCacheResult in
                    XCTAssertEqual(thirdCacheResult, true)
                    cachedThirdExp.fulfill()
                    
                    
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
                    database.getUrlsWith(minlastAccessDate: minDate, completion: {
                        fileSystemUrls in
                        //print(url)
                        XCTAssert(fileSystemUrls.contains(firstFileSystemUrl))
                        XCTAssert(fileSystemUrls.contains(secondFileSystemUrl))
                        
                        XCTAssertNotEqual(fileSystemUrls.contains(thirdFileSystemUrl), true)
                        verifyUrlsBeforeDate.fulfill()
                    })
                   })
                })
                
             })
            
            
        })
        
        waitForExpectations(timeout: 20, handler: nil)
        
        
        let _ =  database.deleteDataBase()
    }
    
    
    
    
    
    
    
    
    
    
}
