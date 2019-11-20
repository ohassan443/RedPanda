//
//  TableImageLoader.swift
//  RedPanda
//
//  Created by omarHassan on 1/23/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//
import Foundation
import UIKit


fileprivate let   runAtMainAsync : (_ :@escaping ()->()  )->() = { operation in
          DispatchQueue.main.async {
              operation()
          }
      }

public class ImageCollectionLoader  : ImageCollectionLoaderProtocol  {
    
    /// requests to be processed
    private var processingRequests 			 	: SyncedAccessHashableCollection<imageRequest> =  SyncedAccessHashableCollection<imageRequest>.init(array: [])
    
    private var preProcessingRequests           : SyncedAccessHashableCollection<imageRequest> =  SyncedAccessHashableCollection<imageRequest>.init(array: [])
    /// requests that failed due to network error / internet error ,,, kept in this list to be retried when network state change or when internet connectivity reutrnes
    private var networkFailedRequests   : SyncedAccessHashableCollection<imageRequest> =  SyncedAccessHashableCollection<imageRequest>.init(array: [])
    
    /// requests that returned invalid data / failed to parse data to an image , kept in this list to avoid requesteing them again
    private var invalidRequests 		: SyncedAccessHashableCollection<String> = SyncedAccessHashableCollection<String>.init(array: []) // failed image parsing - failed data
    
    /// timer used to retry requests that failed due to netwok error
    private var timer : Timer?
    
    /// the interval between each timer retry
    private var timerDelay : TimeInterval = 3
    
    /// the image to retun when the requested url is not valid
    private let invalidRequestImage : UIImage? = nil
    
    /// reachability status (wifi / cellular / none)
    public var connected : Bool = false
    
    
    /// image loader -> has ram cache and disk cache and can load data from server if both return nil
    private var imageLoader : ImageLoaderProtocol
    
    /// monitors reachability changes (Wifi / cellular / none)
    private var reachability : ReachabilityMonitorProtocol
    
    /// bings the server to check for internet avaliablity
    private var connectivityChecker : InternetCheckerProtocol
        
    private var requestsQueue = DispatchQueue(label: "queuex", qos: .userInteractive,attributes: .concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: DispatchQueue.global(qos: .userInteractive))
    
    private var checkingInternet = false
    private let internetCheckingLock = DispatchSemaphore(value: 1)
    
    
    private var retryingFailedRequests = false
    private let retryingFailedRequestsLock = DispatchSemaphore(value: 1)
    
    
    /// init
    init(imageLoader:ImageLoaderProtocol, reachability:ReachabilityMonitorProtocol,connectivityChecker:InternetCheckerProtocol) {
        self.imageLoader = imageLoader
        self.reachability = reachability
        self.connectivityChecker = connectivityChecker
        
    }
  
    
    /// change the interval with which the failed requests will be retried
    public func changeTimerRetry(interval: TimeInterval) {
        self.timerDelay = interval
    }
    /**
     - make an async request for an image with a url  - indexPath - tag - request date
     - the indexPath and request date and the  will be returned in the success handler so the caller can differentiate between the returned images
     - the tag is used to differentate betweeen two requests wil the same url and indexpath so they will be treated as two different requests at this module level - but they will still access the same cache so if one is loaded the other doesnot have too
    
     - returns : request state
         + currently loading : this request is a duplicate of a request that is already loading now ,,,,, to avoid making redudant requests at every cellForRow call for example
         + invalid : the request was made earlier and succeeded but the result data was nil or couldnot be parsed to an image
         + processing : means that this is a new request which is not a duplicate of any currently running request or with any previously failed requests (parsing error / nil data ) and it is currently being processed
    
    */
    public func requestImage(requestDate : Date
        , url:String
        ,indexPath:IndexPath
        ,tag:String
        ,successHandler:@escaping (_ image:UIImage,_ indexPath:IndexPath,_ requestDate:Date)->()
        ,failedHandler: ((_ failedRequest:imageRequest?,_ image:UIImage?,_ requestState:imageRequest.RequestState.AsynchronousCallBack)->())? = nil )-> Void{
        
        
        
        
        self.imageLoader.queryRamCacheFor(url: url, result: { ramImage in
            if let ramImage = ramImage {
                runAtMainAsync{ successHandler(ramImage,indexPath,requestDate)}
                return
            }
            
            
            self.requestsQueue.async { [weak self] in
                guard let self = self else {return}
                
                
                
                
                let request = self.createRequest(requestDate: requestDate, url: url, indexPath: indexPath, tag: tag, successHandler: successHandler,failedHandler: failedHandler)
                
                
          
                self.processingRequests.syncedInsert(element: request, completion: {
                    inserted in
                    switch inserted {
                    case .fail(currentElement: let element) :
//                        guard element.currentlyLoading else {
//                            print("should not enter here")
//                            return
//                        }
                        runAtMainAsync { failedHandler?(nil, self.invalidRequestImage, .currentlyLoading) }
                        return
                        
                    
                    case .success :
                        /// check that url does not refer to corrupt or expired or removed image
                        self.invalidRequests.syncCheckContaines(elementHashValue: url.hashValue, result: {
                            invalid in
                            
                            guard !invalid else {
                                runAtMainAsync{ failedHandler?(nil, self.invalidRequestImage, .invalid)}
                                return
                            }
                            
                            /// if this call was made earlier and failed due to network or internet error then remove if from the 'failed requests list' and execute it now
                            /// the requests in the failed requests list will be retried when the ( network connection / internet ) returns
                            self.networkFailedRequests.specialSyncedRead(url: url, indexPath: indexPath, tag: tag, result: {
                                failedRequest in
                                if let failedRequest = failedRequest {
                                    self.networkFailedRequests.syncedRemove(element: failedRequest, completion: {
                                        self.execute(request: request, alreadyExecutingHandler: {
                                          failedHandler?(request, nil, .currentlyLoading)
                                        })
                                    })
                                }else{
                                     self.execute(request: request, alreadyExecutingHandler: {
                                       failedHandler?(request, nil, .currentlyLoading)
                                     })
                                }
                            })
                        })
                    }
                })
            }
        })
    }
    
    
    private func createRequest(requestDate : Date
    , url:String
    ,indexPath:IndexPath
    ,tag:String
    ,successHandler:@escaping (_ image:UIImage,_ indexPath:IndexPath,_ requestDate:Date)->()
    ,failedHandler: ((_ failedRequest:imageRequest?,_ image:UIImage?,_ requestState:imageRequest.RequestState.AsynchronousCallBack)->())? = nil)-> imageRequest{
        /// the request execution completionHandler
        let request = imageRequest( url: url, loading: false, dateRequestedAt: requestDate, cellIndexPath: indexPath, tag: tag, completion: {[weak self]
            result  in
            
            /// check that the instance is not deallocated - guard aganist slow network calls and memory leaks
            guard let tableImageLoader = self else{//print("deallocated")
                return
            }
            /// check that the result request indexpath is the same as the requested indexpath as a double check
            guard  result.getIndexPath() == indexPath else { //print("image requested for differenet indexPath")
                return
            }
            
            /// switch on the response and execute success or fail handlers accordingly
            switch result {
            case .success(let params):
                DispatchQueue.main.async {
                    successHandler(params.image , params.indexPath , params.date)
                }
                return
                
            case .fail(let params):
                
                switch params.error {
                /// notify the caller that the request failed because the image cant be parsed or expired link ,....
                case .imageParsingFailed,.nilData :
                    DispatchQueue.main.async {
                        failedHandler?(params.request, tableImageLoader.invalidRequestImage, .invalid)
                    }
                    return
                /// do not notify the caller because the request will be retried when the network or the internet problem is resolved
                case .networkError :
                    break // will retry
                }
            }
        })
        return request
    }
    
    
    
    /// execute request
    fileprivate func execute(request:imageRequest,alreadyExecutingHandler : @escaping ()->()) -> Void {
            var req = request
            req.setLoading()
            self.processingRequests.syncedUpdate(element: req, completion: {[weak self] in
                guard let self = self else {return}
                self.imageLoader.getImageFrom(urlString: req.requestUrl
                    , completion: {
                        [weak self]
                        image in
                        guard let tableImageLoader = self else {return}
                        tableImageLoader.loadImageSuccessHandler(request: req, loadedImage: image)
                    }
                    ,fail : { [weak self]
                        failedUrl,error in
                        guard let tableImageLoader = self else {return}
                        
                        tableImageLoader.loadImageFailHandler(request: req,error: error)
                })
            })
    }
    
    
    
    
    /// retry a failed request by copying it and reseting it (failed count & loading status ) and removing it from failed requests , add it to processing requests and then execute it
    private func retry(request:imageRequest,afterInterval:TimeInterval){
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + afterInterval, execute: {[weak self] in
            guard let tableImageLoader = self else {return}
            
            var newRequest = request
            newRequest.reset()
            
            tableImageLoader.execute(request: newRequest, alreadyExecutingHandler: {})
           
        })
        
    }
    
    
    
    
    
    
    @objc private func retryFailedRequests()->Void{
        retryingFailedRequestsLock.wait()
        guard retryingFailedRequests == false else {
            retryingFailedRequestsLock.signal()
            return}
        retryingFailedRequests = true
        retryingFailedRequestsLock.signal()
        networkFailedRequests.syncCheckEmpty(result: {[weak self]
            empty in
            guard let self = self else {return}
            guard empty == false else{
                self.timer?.invalidate()
                self.retryingFailedRequests = false
                return
            }
           
            let requestsToTry = self.networkFailedRequests.getValues()
//             self.networkFailedRequests.refresh()
//            self.networkFailedRequests =  SyncedAccessHashableCollection<imageRequest>.init(array: [])
            
            self.retryingFailedRequests = false
            requestsToTry.enumerated().forEach(){
                index,pair in
                let request = pair.value
                self.processingRequests.syncedInsert(element: request, completion: {_ in
                    self.execute(request: request, alreadyExecutingHandler: {})
                })
            }
            
        })
    }
    
    
    
    
    
    /*
     execute the completion block & and add image to the (url:String,image:UIImage) list if its not added
     */
    private func loadImageSuccessHandler(request:imageRequest,loadedImage:UIImage) -> Void {
        let response = RequestResponse.success(params: successparams(image: loadedImage, date: request.date, indexPath: request.indexPath))
        
        
        request.executeCompletionHandler(response: response)
        processingRequests.syncedRemove(element: request, completion: {})
        networkFailedRequests.syncedRemove(element: request, completion: {})
    }
    
    
    
    
    
    
    /*
     
     */
    private func loadImageFailHandler(request:imageRequest,error:Error)->Void {
        
        processingRequests.specialSyncedRead(url: request.requestUrl, indexPath: request.indexPath, tag: request.requestTag,result: {[weak self]
            found in
            guard found != nil else {return}
            guard let self = self else {return}

            var failedRequest = request
            failedRequest.addFailedAttemp()
            self.processingRequests.syncedUpdate(element: failedRequest,completion: { [weak self]  in
                guard let self = self else {return}
                
                
                
                
                
                
                switch error {
                case imageLoadingError.imageParsingFailed,imageLoadingError.nilData :
                    // corrupt image or invalid ImageData
                    // such as expired Amazon urls
                    // these requests (urls) should not be retired and should be guarded aganist in future requests
                    
                    self.invalidRequests.syncedInsert(element: failedRequest.requestUrl, completion: {_ in 
                        self.processingRequests.syncedRemove(element: failedRequest, completion: {
                            
                            let parameters =  RequestResponse.fail( params: failparams(error: error as! imageLoadingError, request: failedRequest))
                            request.executeCompletionHandler(response: parameters)
                        })
                    })
                    return
                    
                    
                case (let networkError as NSError ) where ImageLoaderNetworkErrorCodes.contains(URLError.Code(rawValue: networkError.code)):
                    /*
                     - these requests failed due to network reasons but should still be processed
                     - these requests will be retried by the timer each time it fires
                     -  exapmles :
                     - requesting while no network is avaliable
                     - requesting wile network is avaliable but no internet connectivity
                     - requesting while in bad network and network keeps droping
                     */
                    
                    self.addToNetworkFailedRequests(request: failedRequest)
                    return
                    
                    
                default :
                    // Example for error that will enter this case :  ---- NSURLErrorDomain Code=-1200 \"An SSL error has occurred and a secure connection to the server cannot be made.\
                    
                    
                    
                    var failedRequest = request
                    failedRequest.addFailedAttemp()
                    self.processingRequests.syncedUpdate(element: failedRequest, completion: {
                        //if request did not reach max attepmt count then reexecute it again
                                      guard  failedRequest.reachedMaxFailCount == true else {
                                          self.retry(request: failedRequest, afterInterval: 1)
                                          return
                                      }
                                      
                                      // this request reached the max number of consecitive retries and its execution will be deferred to the next fire of the timer
                                      failedRequest.reset()
                                      self.addToNetworkFailedRequests(request: failedRequest)
                    })
                }

            })
            
        })
      }
    
    
    
    
    
    /// adds a request to network failed request list and removes it from the currently processing list and run the timer check
    private func addToNetworkFailedRequests(request:imageRequest){
        networkFailedRequests.syncedInsert(element: request, completion: {_ in 
            self.processingRequests.syncedRemove(element: request, completion: {
                 /// check wether the timer is currently running and if it is running then skip as the failed requests will be tried at the next fire
                guard self.timer == nil else {return}
                self.networkFailedRequests.syncCheckEmpty(result: {
                    empty in
                    guard !empty && self.checkingInternet == false else {return}
                    self.checkInternet()
                })
            })
        })
    }
    
    
    
    
    

    /// if ncase the timer is not running then check that there is requests in the failed request list and fire the internet check
    /// if the internet bing succeeds then retry the failed requests , if not then  start the timer
    private func checkInternet() -> Void{
        internetCheckingLock.wait()
        guard checkingInternet == false else {
            internetCheckingLock.signal()
            return
        }
        checkingInternet = true
        internetCheckingLock.signal()
        connectivityChecker.check(completionHandler: {
            [weak self]
            result in
            guard let self = self else {return}
           
            if result {
                self.timer?.invalidate()
                self.retryFailedRequests()
            }else {
                self.runTimer()
            }
             self.checkingInternet = false
        })
    }
    
    
    
    
    
    /// fire a timer that will retry failed requests after certain interval
    private func runTimer() -> Void {
        timer?.invalidate() // check aganist async internet check callback ??? not sure
        self.timer = Timer.scheduledTimer(withTimeInterval: timerDelay, repeats: true, block: {[weak self]
            timer in
            guard let tableImageLoader = self else {return}
            tableImageLoader.retryFailedRequests()
        })
    }
    
    
    
    
    
  
}






extension ImageCollectionLoader : ReachabilityMonitorDelegateProtocol {
    ///
    public func respondToReachabilityChange(reachable: Bool) {
        requestsQueue.async {
            reachable ? (self.retryFailedRequests()) : ()
        }
        self.connected = reachable
    }
    
}


