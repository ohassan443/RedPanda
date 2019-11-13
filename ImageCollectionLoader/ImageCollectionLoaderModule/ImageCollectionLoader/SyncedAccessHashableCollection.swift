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
    
    public func refresh()-> Void{
        timeStamp = Date()
        syncQueue.async(flags : .barrier) {
            self.values = [:]
        }
    }
    
    public func getValues()->[Int:T]{
        var result : [Int:T] = [:]
        syncQueue.sync {
            result = values
        }
        return result
    }
    
    /// insert an intem in the collection
    func syncedInsert(element: T,completion:  @escaping ((_ result : Bool)->())  ) -> Void {
       asyncOperation(operation: {
        guard self.values[element.hashValue] == nil else {
            return false
        }
        self.values[element.hashValue] = element
        return true
       }, onComplete: completion)
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
               }, onComplete: result)
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
    private func asyncOperation<U>(operation : @escaping ()->(U),onComplete:@escaping (U)->()) -> Void {
        let requestDate = timeStamp
        syncQueue.async(flags : .barrier) { [weak self] in
            guard let container = self , container.timeStamp == requestDate else {return}
            let result = operation()
            container.completionQueue.asyncAfter(deadline: .now() + 0.01 , execute: {
                 onComplete(result)
            })
        }
    }
    
    
}
