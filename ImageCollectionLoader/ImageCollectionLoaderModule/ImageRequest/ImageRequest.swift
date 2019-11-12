//
//  ImageRequest.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 1/30/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import UIKit
public struct imageRequest : Hashable {
    public typealias cacheQueryResponse = (state:imageRequest.RequestState,image:UIImage?)
    public enum RequestState {
        
        case RamCache (SynchronousCheck)
        case NetworkOrDiskCache(AsynchronousCallBack)
        
        
        /// states for async requesting of an image
        public enum AsynchronousCallBack {
            
            /// another request with the same indexpath - tag - url was requested and is loading now
            case currentlyLoading
            
            /// the requested url was loaded before and the parsing of the image failed
            case invalid
            
            /// the request is being processed
            case processing
        }
        
        public enum SynchronousCheck {
            /// the requested image for the url is cached in the ram cache
            case cached
             /// the requested url was loaded before and the parsing of the image failed
            case invalid
            /// the requested image for the  url is not avaliable in the ram cache
            case notAvaliable
        }
    }
    
    
    
    private var url : String
    private var loading : Bool
    private var dateRequestedAt : Date
    private var cellIndexPath : IndexPath
    private var completion : ImageCollectionLoaderRequestCompletionHandler? = nil
    
    /// number of times the request was tried and failed
    private var failedCount = 0
    
    /// max number of failed attempts
    private var maxAttemptCount = 0
    private var tag : String
    
    
    var reachedMaxFailCount :Bool {
        return !(failedCount < maxAttemptCount)
    }
    
    var currentlyLoading : Bool {
        return loading
        
    }
    
    var requestUrl : String {
        return self.url
    }
    
    var date : Date {
        return self.dateRequestedAt
    }
    
    var indexPath : IndexPath {
        return self.cellIndexPath
    }
    
    /// string to differentiate between same urls for the same indexpath ,,,, for example a card and a logo
    var requestTag : String {
        return self.tag
    }
    
   
    
    public func hash(into hasher: inout Hasher) {
        let keyValue = url + String(cellIndexPath.row) + String(cellIndexPath.section) + tag
        hasher.combine(keyValue)
    }
   
    init(url:String,loading:Bool,dateRequestedAt : Date,cellIndexPath : IndexPath,tag:String,completion: ImageCollectionLoaderRequestCompletionHandler? = nil) {
        self.url = url
        self.loading = loading
        self.failedCount = 0
        self.maxAttemptCount = 3
        self.dateRequestedAt = dateRequestedAt 
        self.cellIndexPath = cellIndexPath
        self.tag = tag
        self.completion = completion ?? {
            params in
            //print("params = \(params)")
        }
        
    }
    
    
    public static func == (lhs: imageRequest, rhs: imageRequest) -> Bool {
        return lhs.url == rhs.url && lhs.cellIndexPath == rhs.cellIndexPath && lhs.tag == rhs.tag
    }
  
    
    /// reset the failed count of the request ,, will be used before the request is retried
    mutating public func reset(){
        self.failedCount  = 0
        self.loading = false
    }
    
    /// adds failed attempt to the count
    mutating public func addFailedAttemp(){
        self.failedCount += 1
        self.loading = false
    }
    
    /// change max number of the failed attempts
    mutating public func set(maxAttemptCount:Int){
        self.maxAttemptCount = maxAttemptCount
    }
    
    mutating public func setLoading(){
        loading = true
    }
    func executeCompletionHandler(response : RequestResponse) -> Void {
        completion?(response)
    }
}

/// convenience wrapper for reading a request in a synced collection by its url & indexPath & tag 
extension SyncedAccessHashableCollection where T == imageRequest {
    func specialSyncedRead(url:String,indexPath:IndexPath,tag:String) -> imageRequest? {
       
        
        let targetHashValue = imageRequest( url: url, loading: false, dateRequestedAt: Date(), cellIndexPath: indexPath, tag: tag).hashValue
        
        let result = syncedRead(targetElementHashValue: targetHashValue)
        
        return result
    }
}
