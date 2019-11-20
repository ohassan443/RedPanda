//
//  TableImageLoaderTests.swift
//  RedPandaTests
//
//  Created by Omar Hassan  on 2/3/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest
@testable import ImageCollectionLoader

class ImageCollectionLoaderTests: XCTestCase {
    
    
    /**
     - provide intialized ram cache to imageLoader then to tableImageLoader
     - query for the initalized url in the cache
     - tableImageLoader should return a valid image on the method 'query' for the cached url , and return nil for not cached url
     
     - reachabiliy and internet checker have no effect as long as the intenet connection is working correctly or images are found in cache
     - in this test provided empty disk cache and reachability with .none and imageLoader with error response to make sure that it looks in the cache only and doesnot use these resources
     */
    func testFoundInCache() {
        
        let testImage = testImage1
        let testUrl = "url To Cache And retreieve"
        
        let imageWrapper = ImageUrlWrapper(url: testUrl, image: testImage)
        
        let set = SyncedAccessHashableCollection<ImageUrlWrapper>.init(array: [imageWrapper])
        
        
        let oneImageRamCache = RamCacheBuilder()
            .with(imageSet: set)
            .mock(storePolicy: .skip, queryPolicy: .checkInSet)
        
        let emptyDiskCache = DiskCacheBuilder().unResponseiveMock()
        
        
        
        let imageLoader = ImageLoaderBuilder()
            .with(ramCache: oneImageRamCache)
            .with(diskCache: emptyDiskCache)
            .loaderMock(response: .ramCache)
        
        
        let reachability = ReachabailityMonitorMock(conncection: .none)
        
        
        let internetChecker = InternetConnectivityCheckerBuilder()
            .with(successResponse: false)
            .Mock()
        
        
        
        let imageCollectionLoader = ImageCollectionLoaderBuilder()
            .with(imageLoader: imageLoader)
            .with(reachability: reachability)
            .with(internetChecker: internetChecker)
            .TESTCustomConcrete()
        
        let expLoadedImage = expectation(description: "loaded Image")
        imageCollectionLoader.requestImage(requestDate: Date(), url: testUrl, indexPath: IndexPath(row: 0, section: 0), tag: "", successHandler: {
            cachedQueryResult ,_,_ in
            
            
            XCTAssertNotNil(cachedQueryResult)
            XCTAssertEqual(  cachedQueryResult.jpegData(compressionQuality: 0.5) , testImage.jpegData(compressionQuality: 0.5))
            expLoadedImage.fulfill()
        }, failedHandler: {
            _,_,_ in
            XCTFail()
        })
        
        
        wait(for: [expLoadedImage], timeout: 1)
    }

    
    /**
     - imageLoader with empty ram cache and empty disk cache
     - good connection -> imageLoader mock returns and image  (as if from server)
     
     
     - reachability -> WIFI
     - internetChecker -> Success
     - reachabiliy and internet checker have no effect as long as the intenet connection is working correctly or images are found in cache
     */
    func testVerGoodConnection() -> Void {
        let testImage = testImage1
        let testUrl = "testImage1"
        
        
        let emptyUnResponseiveRamCache = RamCacheBuilder().unResponsiveMock()
        let emptyDiskCache = DiskCacheBuilder().unResponseiveMock()
        
        
        
        let imageLoader = ImageLoaderBuilder()
            .with(ramCache: emptyUnResponseiveRamCache)
            .with(diskCache:emptyDiskCache)
            .loaderMock(response: .responseImage(image: testImage))
        
        
        let reachability = ReachabailityMonitorMock(conncection: .wifi)
        
        let internetChecker = InternetConnectivityCheckerBuilder()
            .with(successResponse: true)
            .Mock()
        
        let imageCollectionLoader = ImageCollectionLoaderBuilder()
            .with(internetChecker: internetChecker)
            .with(imageLoader: imageLoader)
            .with(reachability: reachability)
            .TESTCustomConcrete()
        
        
        let requestDate = Date()
        let requestIndexPath = IndexPath(row: 0, section: 0)
        let tag = "tag"
        
        
        
        let exp = expectation(description: "loading image")

        
        
        
        
        imageCollectionLoader.requestImage(requestDate: requestDate, url: testUrl , indexPath: requestIndexPath, tag: tag, successHandler: {
            resultImage,indexPath,requestDate in
            XCTAssertEqual(indexPath, requestIndexPath)
            XCTAssertEqual(resultImage.pngData(), testImage.pngData())
            exp.fulfill()
            
        }, failedHandler: {
            _,_,_ in
            XCTFail()
        })
        
        
        waitForExpectations(timeout: 1, handler: nil)
    }



    /**
     - empty ram cahce
     - empty disk cache
     - good connection -> imageLoader Mock
     
     
     - reachability -> WIFI
     - internetChecker -> Success
     - reachabiliy and internet checker have no effect as long as the intenet connection is working correctly or images are found in cache
     
     - request succeeded but vc's requestDate was refreshed before callBack was executed
     */
    func testRequestDateRefreshed() -> Void {
        let testImage = testImage1
        let testUrl = "testImage1"
        
        // imageLoader with response image and empty cache
        
        let unResponseiveRamCache = RamCacheBuilder().unResponsiveMock()
        let unResponsiveDiskCache = DiskCacheBuilder().unResponseiveMock()
        
        let imageLoader = ImageLoaderBuilder()
        .with(ramCache: unResponseiveRamCache)
        .with(diskCache: unResponsiveDiskCache)
        .loaderMock(response: .responseImage(image: testImage))
        
        
        let reachability = ReachabailityMonitorMock(conncection: .wifi)
        let internetChecker = InternetConnectivityCheckerBuilder()
            .with(successResponse: true)
            .Mock()
        
        let imageCollectionLoader = ImageCollectionLoaderBuilder()
            .with(imageLoader: imageLoader)
            .with(reachability: reachability)
            .with(internetChecker: internetChecker)
            .TESTCustomConcrete()
        
        
        var firstDate =  Date()
        
        let requestIndexPath = IndexPath(row: 0, section: 0)
        let tag = "tag"
        
        let exp = expectation(description: "loading image")
        let invertedExp = expectation(description: "neverEnteredHere")
        invertedExp.isInverted = true
        
        imageCollectionLoader.requestImage(requestDate: firstDate, url: testUrl, indexPath: requestIndexPath, tag: tag, successHandler: {
            image,indexpath,requestDate in
            XCTAssertNotEqual(firstDate, requestDate)
            exp.fulfill()
        }, failedHandler: {
            _,_ ,_ in
            XCTFail()
        })
        
        
        
        // change reuqstDate to indicate that the tableView was refreshed
        firstDate = Date()
        
        waitForExpectations(timeout: 1, handler: nil)
    }



    /**
     - empty ram cache
     - empty disk cache
     - parsing (nil data or failed parsing UIImage) -> imageLoader Mock
     
     
     - reachability -> WIFI
     - internetChecker -> Success
     - reachabiliy and internet checker have no effect on this test as it simulates a good connection but bad response
     
     
     - urls of invalidRequests will be ignored after they are first processed
     - invalidRequests are these which  succeed but fail to parse the response image or the date of the response is nil
     
     
     
     - check that the fail handler of the first request is called
     - check at the failing request of the first request that adding another request returns an 'invalid' request state
     - check that the comletion handlers of the second request are never called with an inverted expectation
     
     */
    func testFailedToParseImageData() {
        let testUrl = "testImage1"
        
        let parsingErrors = [imageLoadingError.imageParsingFailed,imageLoadingError.nilData]
        
        
        parsingErrors.forEach(){
            
            error in
            
            let unResponseiveRamCache = RamCacheBuilder().unResponsiveMock()
            let unResponsiveDiskCache = DiskCacheBuilder().unResponseiveMock()
            
            let imageLoader = ImageLoaderBuilder()
                .with(diskCache: unResponsiveDiskCache)
                .with(ramCache: unResponseiveRamCache)
                .loaderMock(response: .throwError(error: error))
            
            
            
            
            let reachability = ReachabailityMonitorMock(conncection: .wifi)
            let internetChecker = InternetConnectivityCheckerBuilder()
                .with(successResponse: true)
                .Mock()
            
            let imageCollectionLoader = ImageCollectionLoaderBuilder()
                .with(internetChecker: internetChecker)
                .with(reachability: reachability)
                .with(imageLoader: imageLoader)
                .TESTCustomConcrete()
            
            
            let firstDate =  Date()
            
            let requestIndexPath = IndexPath(row: 0, section: 0)
            let tag = "tag"
            
            let sectionTimeInvalidRequestExp = expectation(description: "request failed , and requesting it again returns an invalid response ")
            
            
            
            
            
            imageCollectionLoader.requestImage(requestDate:firstDate, url: testUrl, indexPath: requestIndexPath, tag: tag
                , successHandler: {
                    _,_ , _ in
                    XCTFail()
                    
                    
            }, failedHandler: {
                failedRequest,failedRequestImage,firstRequestState in
                
                XCTAssertEqual(firstRequestState, .invalid)
                
                imageCollectionLoader.requestImage(requestDate: firstDate, url: testUrl, indexPath: requestIndexPath, tag: tag, successHandler: {
                    _,_,_ in
                    XCTFail()
                }, failedHandler: {
                    _,_ , secondRequestState in
                    XCTAssertEqual(secondRequestState, .invalid)
                     sectionTimeInvalidRequestExp.fulfill()
                })
               })
            
            
            waitForExpectations(timeout: 5, handler: nil)
        }
    }

    
    
    /**
     - empty cache
     - slow network -> added delay -> imageLoader Mock
     -
     
     - reachability -> WIFI
     - internetChecker -> Success
     - reachabiliy and internet checker have no effect as long as the intenet connection is working correctly or images are found in cache
     
     - simulate that a request requested while its already loading --- in case cell forRow is called multiple time for the same row or internet is slow
     
     */
    func testRequestIsCurrentlyLoading() -> Void {
        let testImage = testImage1
        let testUrl = "testImage1"
        
        
        let unResponseiveRamCache = RamCacheBuilder().unResponsiveMock()
        let unResponsiveDiskCache = DiskCacheBuilder().unResponseiveMock()
        
        let imageLoader = ImageLoaderBuilder()
            .with(diskCache: unResponsiveDiskCache)
            .with(ramCache: unResponseiveRamCache)
            .with(delayInterval: 0)
            .loaderMock(response: .responseImage(image: testImage))
        
      
        
        
        let reachability = ReachabailityMonitorMock(conncection: .wifi)
        let internetChecker = InternetConnectivityCheckerBuilder()
            .with(successResponse: true)
            .Mock()
        
        let imageCollectionLoader = ImageCollectionLoaderBuilder()
            .with(internetChecker: internetChecker)
            .with(reachability: reachability)
            .with(imageLoader: imageLoader)
            .TESTCustomConcrete()
        
        
        let firstDate =  Date()

        let requestIndexPath = IndexPath(row: 0, section: 0)
        let tag = "tag"
        
        let imageLoadedExp = expectation(description: "image loaded")
        
        let expSecondRequestFailed = expectation(description: "first request returned successfully")
        
        
        
        imageCollectionLoader.requestImage(requestDate:firstDate, url: testUrl, indexPath: requestIndexPath, tag: tag, successHandler: {
            resultImage,indexPath,_ in
            
            XCTAssertEqual(resultImage.pngData(), testImage.pngData())
            imageLoadedExp.fulfill()
            
        }, failedHandler: {
            _ ,_,_ in
            XCTFail()
        })
        
        
         imageCollectionLoader.requestImage(requestDate:firstDate, url: testUrl, indexPath: requestIndexPath, tag: tag, successHandler: {
            resultImage,indexPath,_ in
            
           XCTFail()
            
        }, failedHandler: {
            _ ,_ ,secondRequestState in
            XCTAssertEqual(secondRequestState, .currentlyLoading)
            expSecondRequestFailed.fulfill()
            
        })
        
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    

    
    /**
     check that imageCollection Loader keeps trying over requests when they fail due to network drop when the network comes back up
     */
    
    func testNetworkDropThenComeBack() -> Void {
        let testImage = testImage1
        let testUrl = "testImage1"
        
        
        let error = URLError(ImageLoaderNetworkErrorCodes.first!)
        
        
        let unResponseiveRamCache = RamCacheBuilder().unResponsiveMock()
        let unResponsiveDiskCache = DiskCacheBuilder().unResponseiveMock()
        
        let imageLoader = ImageLoaderBuilder()
            .with(diskCache: unResponsiveDiskCache)
            .with(ramCache: unResponseiveRamCache)
            .with(delayInterval: 0)
            .loaderMock(response: .throwError(error: error))
        
        
        let reachability = ReachabailityMonitorMock(conncection: .none)
        let failedInternetChecker = InternetConnectivityCheckerBuilder()
            .with(successResponse: false)
            .Mock()
        
        let imageCollectionLoader = ImageCollectionLoaderBuilder()
            .with(internetChecker: failedInternetChecker)
            .with(reachability: reachability)
            .with(imageLoader: imageLoader)
            .TESTCustomConcrete()
        imageCollectionLoader.changeTimerRetry(interval: 0.1)
        
        
        let firstDate =  Date()
        
        let requestIndexPath = IndexPath(row: 0, section: 0)
        let tag = "tag"
        
        let imageReloadedSuccess = expectation(description: "loading image")
        
        
        
        
        imageCollectionLoader.requestImage(requestDate:firstDate, url: testUrl, indexPath: requestIndexPath, tag: tag, successHandler: {
            resultImage,IndexPath,_ in
            
            
            imageReloadedSuccess.fulfill()
        }, failedHandler: {
            _,_,_ in
           XCTFail()
        })
       
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            failedInternetChecker.change(internetIsAvaliable: true)
            imageLoader.change(returnResponse: .responseImage(image: testImage))
            reachability.changeConnectionState(newState: .wifi)
        })
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
   
    
    /**
     check that imageCollection Loader keeps trying over requests when they fail due to having network but having no internet connection
     */
    
    
    func testInternetDropAndComeBack() {
        InternetConnectivityDropThenComeBack(retryTimerInterval: 0.1, InternetComesBackAfter: 0.2, maxWaitInterval: 2)
        InternetConnectivityDropThenComeBack(retryTimerInterval: 1, InternetComesBackAfter: 0.2, maxWaitInterval: 2)
        InternetConnectivityDropThenComeBack(retryTimerInterval: 0.2, InternetComesBackAfter: 0.2, maxWaitInterval: 2)
        
    }
    
    func InternetConnectivityDropThenComeBack(retryTimerInterval : TimeInterval,InternetComesBackAfter:TimeInterval,maxWaitInterval:TimeInterval) -> Void {
        let testImage = testImage1
        let testUrl = "testImage1"
        
        
        let error = URLError(ImageLoaderNetworkErrorCodes.first!)
        
        
        let unResponseiveRamCache = RamCacheBuilder().unResponsiveMock()
        let unResponsiveDiskCache = DiskCacheBuilder().unResponseiveMock()
        
        let imageLoader = ImageLoaderBuilder()
            .with(diskCache: unResponsiveDiskCache)
            .with(ramCache: unResponseiveRamCache)
            .with(delayInterval: 0)
            .loaderMock(response: .throwError(error: error))
        
        
        let reachability = ReachabailityMonitorMock(conncection: .none)
        let failedInternetChecker = InternetConnectivityCheckerBuilder()
            .with(successResponse: false)
            .Mock()
        
        let imageCollectionLoader = ImageCollectionLoaderBuilder()
            .with(internetChecker: failedInternetChecker)
            .with(reachability: reachability)
            .with(imageLoader: imageLoader)
            .TESTCustomConcrete()
        imageCollectionLoader.changeTimerRetry(interval: retryTimerInterval)
        
        
        let firstDate =  Date()
        
        let requestIndexPath = IndexPath(row: 0, section: 0)
        let tag = "tag"
        
        let imageReloadedSuccess = expectation(description: "loading image")
        
        
    
        
        
        
        let firstRequestState = imageCollectionLoader.requestImage(requestDate:firstDate, url: testUrl, indexPath: requestIndexPath, tag: tag, successHandler: {
            resultImage,IndexPath,_ in
            
            
            imageReloadedSuccess.fulfill()
        }, failedHandler: {
            _,_,_ in
            XCTFail()
        })
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + InternetComesBackAfter, execute: {
            failedInternetChecker.change(internetIsAvaliable: true)
            imageLoader.change(returnResponse: .responseImage(image: testImage))
        })
        
        waitForExpectations(timeout: maxWaitInterval, handler: nil)
    }
    
    
    

    ///https://picsum.photos/id/1/200/200
    ////// check tag colision
    func testSpam() {
        let startDate = Date()
       var images = [String]()
        var expectations = [XCTestExpectation]()
        for i in 0...1000 {
            images.append("https://picsum.photos/id/\(i)/200/200")
            expectations.append(expectation(description: "\(i) not loaded"))
        }



        let imageCollectionLoader = ImageCollectionLoaderBuilder()
            .with(internetChecker: InternetConnectivityCheckerBuilder().with(successResponse: true).Mock())
            .with(reachability: ReachabailityMonitorMock(conncection: .wifi))
            .with(imageLoader: ImageLoaderBuilder().loaderMock(response: .responseImage(image: testImage1)))
            .TESTCustomConcrete()
        imageCollectionLoader.changeTimerRetry(interval: 3)


        let firstDate =  Date()


        for (index,url) in images.enumerated() {

                 imageCollectionLoader.requestImage(requestDate: firstDate, url: url, indexPath: IndexPath(row: index, section: 0), tag: "i", successHandler: {
                    image,indexPath,date in
                    image
                    expectations[index].fulfill()
                },failedHandler: {
                    request , image, requestState in
                    print("failed")
                })

            }


        waitForExpectations(timeout: 100, handler: nil)
        let finishDate = Date()

        let lapsedTime = finishDate.timeIntervalSince1970 - startDate.timeIntervalSince1970

        print("lapsed time = \(lapsedTime)")
    }

    
    
  
    
    func testSpamFromTwoDifferentInstancesSameDiskCache() {
        var urls = [String]()
        for i in 0...1000 {
            urls.append(UITestsConstants.baseUrl + "ttessst\(i)/")
        }
        
        
        var variableServerResponse : (UrlSessionWrapperMock.CallParams) -> () = {
            arguments in
            XCTFail()
        }
        
        let urlSessionMock = UrlSessionWrapperBuilder().mock(placeHolderCallBack: {
            arguments in
           variableServerResponse(arguments)
        })
        let diskCacheMock = DiskCacheBuilder().mock(storePolicy: .store, queryPolicy: .checkInSet)
        
        variableServerResponse = {
            arguments in
            arguments.callBack(testImage1.png(),nil,nil)
        }
        
        
        let imageLoader = ImageLoaderBuilder()
            .with(ramCache: RamCacheBuilder().concrete(maxItemsCount: 20))
            .with(diskCache: diskCacheMock)
            .with(urlSession: urlSessionMock)
            .customConcrete()
            
        
        
        
       
        
     
        
        
        let imageCollectionLoader = ImageCollectionLoaderBuilder()
            .with(internetChecker: InternetConnectivityCheckerBuilder().concrete())
            .with(reachability: ReachabailityMonitor())
            .with(imageLoader: imageLoader)
            .TESTCustomConcrete()
        
        let expLoadedFirstWave = expectation(description: "loaded all images of the first wave ")
        var firstWaveReturnedImages = 0
        for (index,url) in urls.enumerated() {
            imageCollectionLoader.requestImage(requestDate: Date(), url: url, indexPath: IndexPath(row: index, section: 0), tag: "\(index)", successHandler: {
                image,indexPath,_ in
                print("loaded successfully \(indexPath)")
                firstWaveReturnedImages = firstWaveReturnedImages + 1
                firstWaveReturnedImages == urls.count - 1 ? (expLoadedFirstWave.fulfill()) : ()
                
            })
        }
        wait(for: [expLoadedFirstWave], timeout: 5)
        
        
        variableServerResponse = {
                  arguments in
                arguments.callBack(nil,nil,URLError(URLError.networkConnectionLost))
        }
        
        
        
        let expLoadedSecondWave = expectation(description: "loaded all images of the second wave")
        var secondtWaveReturnedImages = 0
        let secondImageCollectionLoader = ImageCollectionLoaderBuilder()
            .with(internetChecker: InternetConnectivityCheckerBuilder().concrete())
            .with(reachability: ReachabailityMonitor())
            .with(imageLoader: imageLoader)
            .TESTCustomConcrete()
        secondImageCollectionLoader.changeTimerRetry(interval: 1)
        
        for (index,url) in urls.enumerated() {
            secondImageCollectionLoader.requestImage(requestDate: Date(), url: url, indexPath: IndexPath(row: index, section: 0), tag: "\(index)", successHandler: {
                image,indexPath,_ in
                print("loaded successfully second \(indexPath)")
                secondtWaveReturnedImages = secondtWaveReturnedImages + 1
                secondtWaveReturnedImages == urls.count - 1 ? (expLoadedSecondWave.fulfill()) : ()
            },failedHandler:{ failedRequest,failedImage,requestState in
          
            XCTFail()
            })
        }
        
        
        wait(for: [expLoadedSecondWave], timeout: 5)

    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}


