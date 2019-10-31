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
        case currentlyLoading
        case invalid
        case processing
        case cached
        case notAvaliable
    }
    
    
    private var image : UIImage?
    private var url : String
    private var loading : Bool
    private var dateRequestedAt : Date
    private var cellIndexPath : IndexPath
    private var completion : ((ImageCollectionLoaderObj.params) -> ())? = nil
    private var failedCount = 0
    private var maxAttemptCount = 0
    private var tag : String
    
    
    var failed :Bool {
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
    
    var requestTag : String {
        return self.tag
    }
    
   
    
    public func hash(into hasher: inout Hasher) {
        let keyValue = url + String(cellIndexPath.row) + String(cellIndexPath.section) + tag
        hasher.combine(keyValue)
    }
   
    init(image:UIImage?,url:String,loading:Bool,dateRequestedAt : Date,cellIndexPath : IndexPath,tag:String,completion: ((ImageCollectionLoaderObj.params)->())? = nil) {
        self.image = image
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
    static func compare(queryRequest:imageRequest,target:(url:String,cellIndexPath:IndexPath,tag:String)) -> Bool {
        return queryRequest.url == target.url && queryRequest.cellIndexPath == target.cellIndexPath && queryRequest.tag == target.tag
    }
    
    static func setContaints(set:Set<imageRequest>,url:String,cellIndexPath:IndexPath,tag:String) -> imageRequest? {
        let result = set.first(where: {
            element in
            return compare(queryRequest: element, target: (url,cellIndexPath,tag))
        })
        return result
    }
    static func setContaints(set:Set<imageRequest>,request:imageRequest) -> imageRequest? {
      return setContaints(set: set, url: request.url, cellIndexPath: request.cellIndexPath, tag: request.tag)
        
    }
    
    
    mutating public func reset(){
        self.failedCount  = 0
        self.loading = false
    }
    mutating public func addFailedAttemp(){
        self.failedCount += 1
        self.loading = false
    }
    mutating public func set(maxAttemptCount:Int){
        self.maxAttemptCount = maxAttemptCount
    }
    
    mutating public func setLoading(){
        loading = true
    }
    func executeCompletionHandler(params:ImageCollectionLoader.params) -> Void {
        completion?(params)
    }
}

extension Set where Element == imageRequest {
   
}
