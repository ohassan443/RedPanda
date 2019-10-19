//
//  TableImageLoader.swift
//  Zabatnee
//
//  Created by omarHassan on 1/23/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//
import Foundation
import UIKit




class ImageCollectionLoader  : ImageCollectionLoaderObj  {
    
    private var requests : Set<imageRequest> = []
    private var networkFailedRequests : Set<imageRequest> = []
    private var invalidRequests : Set<String> = [] // failed image parsing - failed data
    private var timer : Timer?
    private var timerDelay : TimeInterval = 3
    private let invalidRequestImage : UIImage? = nil
    var connected : Bool = false
    
    private var imageLoader : ImageLoaderObj
    private var reachability : ReachabilityMOnitorObj
    private var connectivityChecker : InternetConnectivityCheckerObj
    private let queue 			 = DispatchQueue(label: "customQue \(Date().timeIntervalSince1970)", qos: .userInitiated, attributes: DispatchQueue.Attributes.concurrent)
    private let imageRquestQueue = DispatchQueue(label: "ImageRequests \(Date().timeIntervalSince1970)", qos: .userInitiated, attributes: DispatchQueue.Attributes.concurrent, target: DispatchQueue.global(qos: .userInitiated))
    
    
    init(imageLoader:ImageLoaderObj, reachability:ReachabilityMOnitorObj,connectivityChecker:InternetConnectivityCheckerObj) {
        self.imageLoader = imageLoader
        self.reachability = reachability
        self.connectivityChecker = connectivityChecker
        
        
    }
    
    
    func cacheQueryState(url: String) -> (state:imageRequest.RequestState,image:UIImage?) {
        guard !(url == "") else {return (.cached,UIImage()) }
        
        if invalidRequests.contains(url)  {
            return (.invalid,invalidRequestImage)
        } // url does not contain corrupt or expired or removed image
        
        
        if let image = imageLoader.queryRamCacheFor(url: url){
            return (.cached,image)
        }
        
        
        
        return (.notAvaliable,nil)
    }
    
    
    func changeTimerRetry(interval: TimeInterval) {
        self.timerDelay = interval
    }
    
    
     func requestImage(requestDate : Date
        , url:String
        ,indexPath:IndexPath
        ,tag:String
        ,successHandler:@escaping (_ image:UIImage,_ indexPath:IndexPath,_ requestDate:Date)->()
        ,failedHandler: ((_ failedRequest:imageRequest,_ image:UIImage?)->())? = nil)-> imageRequest.RequestState {
        
        var requestState = imageRequest.RequestState.processing
        imageRquestQueue.sync {
            
            /*
             -check if request is already added
             - if not added then add it and execute it
             - check whether its added and loading now then skip as it will execute the callBack when finished
             
             */
            
            
            /// url does not contain corrupt or expired or removed image
            guard  invalidRequests.contains(url)  == false   else {requestState =  imageRequest.RequestState.invalid ; return}
            
            if let currentlyLoadingRequest = imageRequest.setContaints(set: requests, url: url, cellIndexPath: indexPath, tag: tag),currentlyLoadingRequest.currentlyLoading == true {
                requestState = imageRequest.RequestState.currentlyLoading
                return
            }
            
            
            
            
            
            
            
            
            
            
            
            
            let request = imageRequest(image: nil, url: url, loading: false, dateRequestedAt: requestDate, cellIndexPath: indexPath, tag: tag, completion: {      [weak self]
                result  in
                guard let tableImageLoader = self else{
                    //print("deallocated")
                    return
                }
                guard  result.indexPath == indexPath else {
                    //print("image requested for differenet indexPath")
                    return
                }
                
                
                if result.success == true , let image = result.image{
                    successHandler(image,indexPath, result.dateRequestedAt)
                    return
                }
                
                
                if let loadingError = result.error {
                    
                    switch loadingError {
                    case .imageParsingFailed,.invalidResponse :
                        guard let failedRequest = result.failedRequest else {return}
                        failedHandler?(failedRequest, tableImageLoader.invalidRequestImage)
                    case .networkError :
                        break // will retry
                    }
                }
            })
            
            
            
            if let _ = imageRequest.setContaints(set: networkFailedRequests, request: request){
                networkFailedRequests.remove(request)
            }
            
           
            
            DispatchQueue.main.async {
                self.add(request: request)
                
                self.execute(request: request)
            }
        }
        
        return .processing
    }
    
    
    
    
    
    
    private func add(request: imageRequest)-> Void{
        
        imageRquestQueue.sync {
            var newRequest = request
            newRequest.reset()
            newRequest.setLoading()
            
            guard let currentRequestInSet =  imageRequest.setContaints(set: requests, request: newRequest)else {
                requests.insert(newRequest)
                return
            }
            
            guard currentRequestInSet.date != request.date else {return}
            
            requests.update(with: newRequest)
        }
        
    }
    
    
    
    fileprivate func execute(request:imageRequest) -> Void {
         imageRquestQueue.sync {
        guard let addedRequest = imageRequest.setContaints(set: requests, request: request) else {return}
        var req = addedRequest
        req.setLoading()
        requests.update(with: req)
        
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
    }
    
    
    
    
    
    private func retry(request:imageRequest){
        imageRquestQueue.asyncAfter(deadline: .now() + 1, execute: {[weak self] in
            guard let tableImageLoader = self else {return}
            
            var newRequest = request
            newRequest.reset()
            tableImageLoader.networkFailedRequests.remove(newRequest)
            
            guard tableImageLoader.requests.insert(newRequest).inserted == true else {return}
            
            tableImageLoader.execute(request: newRequest)
        })

    }
    
    
    
    
    
    
    private func retryFailedRequests()->Void{
        imageRquestQueue.sync {
            let requestsToTry = networkFailedRequests
            networkFailedRequests = []
            
            
            requestsToTry.forEach(){
                request in
                
                guard requests.insert(request).inserted == true else {return}
                execute(request: request)
            }
        }
   }
    
    
    
    
   
   /*
     execute the completion block & and add image to the (url:String,image:UIImage) list if its not added
     */
    private func loadImageSuccessHandler(request:imageRequest,loadedImage:UIImage) -> Void {
         imageRquestQueue.sync {
        let parameters = params(true,loadedImage,request.date,request.indexPath,request,nil)
        request.executeCompletionHandler(params: parameters)
        requests.remove(request)
        }
    }
    
    
    
    
    
    
    /*
     
     */
    private func loadImageFailHandler(request:imageRequest,error:Error)->Void {
        imageRquestQueue.sync {
            guard let _ = imageRequest.setContaints(set: requests, url: request.requestUrl, cellIndexPath: request.indexPath, tag: request.requestTag)else {return}
            
            var failedRequest = request
            failedRequest.addFailedAttemp()
            requests.update(with: failedRequest)
            
            switch error {
            case imageLoadingError.imageParsingFailed,imageLoadingError.invalidResponse :
                // corrupt image or invalid ImageData
                // such as expired Amazon urls
                // these requests (urls) should not be retired and should be guarded aganist in future requests
                
                invalidRequests.insert(failedRequest.requestUrl)
                requests.remove(failedRequest)
                
                let parameters = params(false,nil,failedRequest.date,request.indexPath,failedRequest,error as? imageLoadingError)
                request.executeCompletionHandler(params: parameters)
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
                let parameters = params(false,nil,failedRequest.date,request.indexPath,failedRequest,imageLoadingError.networkError)
                request.executeCompletionHandler(params: parameters)
                
                addToNetworkFailedRequests(request: failedRequest)
                return
                
                
            default :
                // Example for error that will enter this case :  ---- NSURLErrorDomain Code=-1200 \"An SSL error has occurred and a secure connection to the server cannot be made.\
                
                
                
                var failedRequest = request
                failedRequest.addFailedAttemp()
                requests.update(with: failedRequest)
                
                //if request did not reach max attepmt count then reexecute it again
                guard  failedRequest.failed == true else {
                    retry(request: failedRequest)
                    return
                }
                
                // this request reached the max number of consecitive retries and its execution will be deferred to the next fire of the timer
                failedRequest.reset()
                addToNetworkFailedRequests(request: failedRequest)
                
            }
        }
    }
    
    
    
    
    
    
    private func addToNetworkFailedRequests(request:imageRequest){
        imageRquestQueue.sync {
            networkFailedRequests.insert(request)
            requests.remove(request)
            runTimerCheck()

        }
    }
    
    
    
    
    
    
    private func runTimerCheck() -> Void{
        
        guard timer == nil else {return}
        let requestsFailed = !networkFailedRequests.isEmpty
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
        guard networkFailedRequests.isEmpty == false else {
            timer?.invalidate()
            return
        }
        retryFailedRequests()
    }
}






extension ImageCollectionLoader : ReachabilityMonitorDelegate {
    func respondToReachabilityChange(reachable: Bool) {
        reachable ? (retryFailedRequests()) : ()
        self.connected = reachable
    }
    
}


