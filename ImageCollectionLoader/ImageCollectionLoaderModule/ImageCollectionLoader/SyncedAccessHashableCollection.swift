//
//  SyncedDic.swift
//  ImageCollectionLoader
//
//  Created by Omar Hassan  on 11/10/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation


/// synced collection to avoid multiple writes crashing
class SyncedAccessHashableCollection<T: Hashable>{
    private var values : [Int:T] = [:]
    private var timeStamp = Date()
    
    private let syncQueue =  DispatchQueue(label: "syncedCollectionQueue", qos :.userInteractive, attributes: DispatchQueue.Attributes.concurrent)
    private let completionQueue = DispatchQueue(label: "syncedCollectionQueueCompletion", qos:.userInteractive, attributes: DispatchQueue.Attributes.concurrent)
    
    
    init(array:[T]) {
        array.forEach(){
            values[$0.hashValue] = $0
        }
    }
    
     func refreshAnDiscardQueueUpdates(completion:(()->())? = nil)-> Void{
        timeStamp = Date()
        asyncOperation(operation: {
            self.values = [:]
        }, onComplete: {
            completion?()
        })
    }
    
     func getValues()->[Int:T]{
        var result : [Int:T] = [:]
        syncQueue.sync {
            result = values
        }
        return result
    }
    
    enum InsertResult {
        case success
        case fail(currentElement:T)
    }
    /// insert an intem in the collection
    func syncedInsert(element: T,maxCountRefresh:Int? = nil,completion:  @escaping ((_ result : InsertResult)->())  ) -> Void {
       asyncOperation(operation: {
        if let maxCount = maxCountRefresh,self.values.count >= maxCount  {
            self.timeStamp = Date()
            self.values = [:]
            print("refreshed at \(element)")
        }
        
        if let currentElement = self.values[element.hashValue]{
            return .fail(currentElement: self.values[element.hashValue]!)
        }else {
            self.values[element.hashValue] = element
            return .success
        }
       }, onComplete: completion,considerTimeStamp: false)
    }
    
    
    /// remove and item from the collection
    func syncedRemove(element:T,completion: @escaping (()->())) -> Void {
      
        asyncOperation(operation: {
            self.values[element.hashValue] = nil
            return
        }, onComplete: completion)
    }
    
    /// update the value of an item in the collection
    func syncedUpdate(element:T,completion: @escaping (()->())) -> Void {
      asyncOperation(operation: {
         self.values[element.hashValue] = element
        return
      }, onComplete: completion)
    }
    
    
    /// read the element in the collection with the hash valaue passed
    func syncedRead(targetElementHashValue:Int,result :@escaping (T?)->()) -> Void {
        asyncOperation(operation: {
                   return self.values[targetElementHashValue]
               }, onComplete: result,considerTimeStamp: false)
    }
    
    /// check wether an element is avaliable in the collection with the passed hash value
    func syncCheckContaines(elementHashValue:Int ,result : @escaping (Bool)->()) -> Void {
        asyncOperation(operation: {
            return self.values[elementHashValue] != nil
        }, onComplete: result)
    }
    
    /// check wether the collection is empty
    func syncCheckEmpty(result :@escaping (Bool)->()) -> Void {
      asyncOperation(operation: {
        return self.values.isEmpty
      }, onComplete: result)
    }
    
    
    /// run the operation Asynchronously with a barrier flag to avoid memory crashes 
    private func asyncOperation<U>(operation : @escaping ()->(U),onComplete:@escaping (U)->(),considerTimeStamp : Bool = true) -> Void {
        let requestDate = timeStamp
        syncQueue.async(flags : .barrier) { [weak self] in
            guard let container = self else {return}
            if considerTimeStamp && container.timeStamp != requestDate {
                return
            }
            let result = operation()
            container.completionQueue.asyncAfter(deadline: .now()  , execute: {
                 onComplete(result)
            })
        }
    }
    
    
}
