//
//  ImageRequestTests.swift
//  ZabatneeTests
//
//  Created by Omar Hassan  on 2/3/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest
@testable import ImageCollectionLoader

class ImageRequestTests: XCTestCase {
    
    let request = imageRequest(image: nil, url: "1", loading: false, dateRequestedAt: Date(), cellIndexPath: IndexPath(row: 0, section: 0), tag: "1")
    let duplicatedRequest = imageRequest(image: UIImage(), url: "1", loading: true, dateRequestedAt: Date(), cellIndexPath: IndexPath(row: 0, section: 0), tag: "1")
    
    /**
     - imageRequest is hashed by url + indexpath row + indexPath section + tag
     - as long as these four values are euqal the request is treated as duplicate
     */
    
    func testEquality() {
        
        // changing image or loading status Bool or dateRequestedAt has no effect on the equality of two requests
        let r1 = request
        let r2 = duplicatedRequest
        
        XCTAssertEqual(r1, r2)
        
        // change url & requests should fail equality
        let r3 = imageRequest(image: nil, url: "2", loading: false, dateRequestedAt: Date(), cellIndexPath: IndexPath(row: 0, section: 0), tag: "1")
        XCTAssertNotEqual(r3, r1)
        
        // change IndexPath row & requests should fail equality
        let r4 = imageRequest(image: nil, url: "1", loading: false, dateRequestedAt: Date(), cellIndexPath: IndexPath(row: 1, section: 0), tag: "1")
        XCTAssertNotEqual(r4, r1)
        
        // change IndexPath section & requests should fail equality
        let r5 = imageRequest(image: nil, url: "1", loading: false, dateRequestedAt: Date(), cellIndexPath: IndexPath(row: 0, section: 1), tag: "1")
        XCTAssertNotEqual(r5, r1)
        
        // change  tag & requests should fail equality
        let r6 = imageRequest(image: nil, url: "1", loading: false, dateRequestedAt: Date(), cellIndexPath: IndexPath(row: 0, section: 0), tag: "2")
        XCTAssertNotEqual(r6, r1)
    }
    
    func testSetCollision() -> Void {
        let r1 = request
        let r2 = duplicatedRequest
        
        var set : Set<imageRequest> = []
        
        
        let insertR1 = set.insert(r1)
        XCTAssertEqual(insertR1.inserted, true)
        
        // insertion fails as they are duplicate by hashValue
        let insertR2 = set.insert(r2)
        XCTAssertEqual(insertR2.inserted, false)
        
        
        
    }
    func testSetSearch() -> Void {
        let r1 = request
        
         var set : Set<imageRequest> = []
        
        let insertR1 = set.insert(r1)
        XCTAssertEqual(insertR1.inserted, true)
        
        
        
        let searchR1 = set.contains(r1)
        XCTAssertTrue(searchR1)
        
        
       
        
        
        let r2 = imageRequest(image: nil, url: "newUrl", loading: false, dateRequestedAt: Date(), cellIndexPath: IndexPath(row: 0, section: 0), tag: "newTag")
        
        let searchR2 = set.contains(r2)
        XCTAssertFalse(searchR2)
    }
    
    
    
    // excceding max attempts count sets the failed flag to true
    func testExccedingMaxAttemptCountFails() {
        var r1 = imageRequest(image: nil, url: "", loading: true, dateRequestedAt: Date(), cellIndexPath: IndexPath(row: 0, section: 0), tag: "")
        
        r1.set(maxAttemptCount: 3)
        XCTAssertEqual(r1.failed, false)
        
        
        for _ in stride(from: 0, through: 4, by: 1) {
            r1.addFailedAttemp()
        }
        
        XCTAssertEqual(r1.failed, true)
    }
    
    // test failed flag after reaching max attempt count then failing
    func testReset() {
        var r1 = imageRequest(image: nil, url: "", loading: true, dateRequestedAt: Date(), cellIndexPath: IndexPath(row: 0, section: 0), tag: "")
        
        r1.set(maxAttemptCount: 3)
        XCTAssertEqual(r1.failed, false)
        
        
        for _ in stride(from: 0, through: 4, by: 1) {
            r1.addFailedAttemp()
        }
        
        XCTAssertEqual(r1.failed, true)
        
        r1.reset()
        
        XCTAssertEqual(r1.currentlyLoading, false)
        XCTAssertEqual(r1.failed, false)
    }
    
    
    
}
