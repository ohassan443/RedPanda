//
//  TableImageLoader.swift
//  Zabatnee
//
//  Created by omarHassan on 1/23/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//
import Foundation
import UIKit



extension SyncedDic where T == imageRequest {
    func specialSyncedRead(url:String,indexPath:IndexPath,tag:String) -> imageRequest? {
       
        
        let targetHashValue = imageRequest(image: nil, url: url, loading: false, dateRequestedAt: Date(), cellIndexPath: indexPath, tag: tag).hashValue
        
        let result = syncedRead(targetElementHashValue: targetHashValue)
        
        return result
    }
}

public class ImageCollectionLoader  : ImageCollectionLoaderObj  {
    
    private var requests 			 	: SyncedDic<imageRequest> =  SyncedDic<imageRequest>.init()
    private var networkFailedRequests   : SyncedDic<imageRequest> =  SyncedDic<imageRequest>.init()
    private var invalidRequests 		: SyncedDic<String> = SyncedDic<String>.init() // failed image parsing - failed data
    private var timer : Timer?
    private var timerDelay : TimeInterval = 3
    private let invalidRequestImage : UIImage? = nil
    public var connected : Bool = false
    
    private var imageLoader : ImageLoaderObj
    private var reachability : ReachabilityMOnitorObj
    private var connectivityChecker : InternetConnectivityCheckerObj
    
    let imageRequestQueue = DispatchQueue(label: "realmClientQueue", qos: .userInitiated, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: DispatchQueue.global(qos: .userInitiated))
    
    init(imageLoader:ImageLoaderObj, reachability:ReachabilityMOnitorObj,connectivityChecker:InternetConnectivityCheckerObj) {
        self.imageLoader = imageLoader
        self.reachability = reachability
        self.connectivityChecker = connectivityChecker
        
    }
    
    
    public func cacheQueryState(url: String) -> (state:imageRequest.RequestState,image:UIImage?) {
        guard !(url == "") else {return (.cached,UIImage()) }

        
        if invalidRequests.syncCheckContaines(elementHashValue: url.hashValue){
                 return (.invalid,invalidRequestImage)
        }
        
        
        
        if let image = imageLoader.queryRamCacheFor(url: url){
            return (.cached,image)
        }
        
        
        
        return (.notAvaliable,nil)
    }
    
    
    public func changeTimerRetry(interval: TimeInterval) {
        self.timerDelay = interval
    }
    
    
    public func requestImage(requestDate : Date
        , url:String
        ,indexPath:IndexPath
        ,tag:String
        ,successHandler:@escaping (_ image:UIImage,_ indexPath:IndexPath,_ requestDate:Date)->()
        ,failedHandler: ((_ failedRequest:imageRequest,_ image:UIImage?)->())? = nil)-> imageRequest.RequestState {
        
        
        
        /*
         -check if request is already added
         - if not added then add it and execute it
         - check whether its added and loading now then skip as it will execute the callBack when finished
         
         */
        
        
        /// url does not contain corrupt or expired or removed image
        guard  invalidRequests.syncCheckContaines(elementHashValue: url.hashValue)  == false   else {return imageRequest.RequestState.invalid}
        
        if let currentlyLoadingRequest = requests.specialSyncedRead(url: url, indexPath: indexPath, tag: tag) , currentlyLoadingRequest.currentlyLoading == true{
             return imageRequest.RequestState.currentlyLoading
        }
        
        
        
        
        
        
        
        
        
        
        
        
        let request = imageRequest(image: nil, url: url, loading: false, dateRequestedAt: requestDate, cellIndexPath: indexPath, tag: tag, completion: {      [weak self]
            result  in
            guard let tableImageLoader = self else{//print("deallocated")
                return
            }
            guard  result.getIndexPath() == indexPath else { //print("image requested for differenet indexPath")
                return
            }
            
            switch result {
            case .success(let params):
                successHandler(params.image,params.indexPath, params.date )
                return
                
            case .fail(let params):
                
                switch params.error {
                case .imageParsingFailed,.nilData :
                    failedHandler?(params.request, tableImageLoader.invalidRequestImage)
                case .networkError :
                    break // will retry
                }
            }
        })
        
        
        if let _ = networkFailedRequests.specialSyncedRead(url: url, indexPath: indexPath, tag: tag){
           networkFailedRequests.syncedRemove(element: request)
        }
       
        
        add(request: request)
        
        
   
        self.execute(request: request)
      
        return .processing
    }
    
    
    
    
    
    
    private func add(request: imageRequest)-> Void{
        
        var newRequest = request
        newRequest.reset()
        newRequest.setLoading()
        
        
        guard let currentRequestInSet = requests.syncedRead(targetElementHashValue: newRequest.hashValue) else {
            requests.syncedInsert(element: newRequest)
            return
        }
        
        guard currentRequestInSet.date != request.date else {return}
        requests.syncedUpdate(element: newRequest)
    }
    
    
    
    fileprivate func execute(request:imageRequest) -> Void {
        
        guard requests.syncCheckContaines(elementHashValue: request.hashValue) else {return}
        var req = request
        req.setLoading()
        requests.syncedUpdate(element: req)
        
        imageLoader.getImageFrom(urlString: req.requestUrl
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
    }
    
    
    
    
    
    private func retry(request:imageRequest,afterInterval:TimeInterval){
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + afterInterval, execute: {[weak self] in
            guard let tableImageLoader = self else {return}
            
            var newRequest = request
            newRequest.reset()
            
            tableImageLoader.networkFailedRequests.syncedRemove(element: newRequest, completion: {
              
                tableImageLoader.requests.syncedInsert(element: newRequest, completion: {
                      tableImageLoader.execute(request: newRequest)
                })
            })
        })
        
    }
    
    
    
    
    
    
    private func retryFailedRequests()->Void{
        networkFailedRequests.updateTimeStamp()
        let requestsToTry = networkFailedRequests
        
        networkFailedRequests =  SyncedDic<imageRequest>.init()
        
        let requestsToRetry = requestsToTry.values
        requestsToRetry.forEach(){
            pair in
            let request = pair.value
            requests.syncedInsert(element: request, completion: {
                self.execute(request: request)
            })
        }
    }
    
    
    
    
    
    /*
     execute the completion block & and add image to the (url:String,image:UIImage) list if its not added
     */
    private func loadImageSuccessHandler(request:imageRequest,loadedImage:UIImage) -> Void {
        let response = ImageCollectionLoaderRequestResponse.success(params: successparams(image: loadedImage, date: request.date, indexPath: request.indexPath))
        
        
        request.executeCompletionHandler(response: response)
        requests.syncedRemove(element: request, completion: nil)
    }
    
    
    
    
    
    
    /*
     
     */
    private func loadImageFailHandler(request:imageRequest,error:Error)->Void {
        
        guard let _ = requests.specialSyncedRead(url: request.requestUrl, indexPath: request.indexPath, tag: request.requestTag) else {return}
        
        var failedRequest = request
        failedRequest.addFailedAttemp()
        requests.syncedUpdate(element: failedRequest,completion: { [weak self]  in
            guard let self = self else {return}
            
            
            
            
            
            
            switch error {
            case imageLoadingError.imageParsingFailed,imageLoadingError.nilData :
                // corrupt image or invalid ImageData
                // such as expired Amazon urls
                // these requests (urls) should not be retired and should be guarded aganist in future requests
                
                self.invalidRequests.syncedInsert(element: failedRequest.requestUrl, completion: {
                    self.requests.syncedRemove(element: failedRequest, completion: {
                        
                        let parameters =  ImageCollectionLoaderRequestResponse.fail( params: failparams(error: error as! imageLoadingError, request: failedRequest))
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
               
                let parameters =  ImageCollectionLoaderRequestResponse.fail( params: failparams(error: imageLoadingError.networkError, request: failedRequest))
                request.executeCompletionHandler(response: parameters)
                
                self.addToNetworkFailedRequests(request: failedRequest)
                return
                
                
            default :
                // Example for error that will enter this case :  ---- NSURLErrorDomain Code=-1200 \"An SSL error has occurred and a secure connection to the server cannot be made.\
                
                
                
                var failedRequest = request
                failedRequest.addFailedAttemp()
                self.requests.syncedUpdate(element: failedRequest)
                
                //if request did not reach max attepmt count then reexecute it again
                guard  failedRequest.failed == true else {
                    self.retry(request: failedRequest, afterInterval: 1)
                    return
                }
                
                // this request reached the max number of consecitive retries and its execution will be deferred to the next fire of the timer
                failedRequest.reset()
                self.addToNetworkFailedRequests(request: failedRequest)
                
            }

        })
    }
    
    
    
    
    
    
    private func addToNetworkFailedRequests(request:imageRequest){
        networkFailedRequests.syncedInsert(element: request, completion: {
            self.requests.syncedRemove(element: request, completion: {
                self.runTimerCheck()
            })
        })
    }
    
    
    
    
    
    
    private func runTimerCheck() -> Void{
        
        guard timer == nil else {return}
        let requestsFailed = !networkFailedRequests.syncCheckEmpty()
        //        let networkExist = connected
        //
        //        guard requestsFailed && networkExist else {return}
        
        guard requestsFailed else {return}
        connectivityChecker.check(completionHandler: {
            [weak self]
            result in
            guard let tableImageLoader = self else {return}
            if result {
                tableImageLoader.timer?.invalidate()
                tableImageLoader.runTimedCode()
            }else {
                tableImageLoader.runTimer()
            }
        })
    }
    
    
    
    
    
    
    private func runTimer() -> Void {
        timer?.invalidate() // check aganist async internet check callback ??? not sure
        self.timer = Timer.scheduledTimer(withTimeInterval: timerDelay, repeats: true, block: {[weak self]
            timer in
            guard let tableImageLoader = self else {return}
            tableImageLoader.runTimedCode()
        })
    }
    
    
    
    
    
    
    @objc private func runTimedCode(){
        guard networkFailedRequests.syncCheckEmpty() == false else {
            timer?.invalidate()
            return
        }
        retryFailedRequests()
    }
}






extension ImageCollectionLoader : ReachabilityMonitorDelegate {
    public func respondToReachabilityChange(reachable: Bool) {
        reachable ? (retryFailedRequests()) : ()
        self.connected = reachable
    }
    
}


