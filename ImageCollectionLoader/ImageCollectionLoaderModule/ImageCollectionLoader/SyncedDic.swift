//
//  SyncedDic.swift
//  ImageCollectionLoader
//
//  Created by Omar Hassan  on 11/10/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation


/// synced collection to avoid multiple writes crashing
class SyncedDic<T: Hashable>{
    var values : [Int:T] = [:]
    private var timeStamp = Date()
    
    let syncQueue =  DispatchQueue(label: "queue", qos: .userInitiated, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: DispatchQueue.global(qos: .userInteractive))
    let completionQueue = DispatchQueue(label: "queue", qos: .userInitiated, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: DispatchQueue.global(qos: .userInteractive))
    
    public func updateTimeStamp()-> Void{
        timeStamp = Date()
    }
    
    
    /// insert an intem in the collection
    func syncedInsert(element: T,completion:  @escaping (()->())  ) -> Void {
        asyncOperation(operation: {
            self.values[element.hashValue] = element
            self.completionQueue.asyncAfter(deadline: .now() + 0.01) {
                 completion()
            }
        })
    }
    
    
    /// remove and item from the collection
    func syncedRemove(element:T,completion: @escaping (()->())) -> Void {
        asyncOperation(operation: {
            self.values[element.hashValue] = nil
            self.completionQueue.asyncAfter(deadline: .now() + 0.01) {
                 completion()
            }
        })
    }
    
    /// update the value of an item in the collection
    func syncedUpdate(element:T,completion: @escaping (()->())) -> Void {
        asyncOperation(operation: {
            self.values[element.hashValue] = element
            self.completionQueue.asyncAfter(deadline: .now() + 0.01) {
                 completion()
            }
        })
        
        
    }
    
    
    /// read the element in the collection with the hash valaue passed
    func syncedRead(targetElementHashValue:Int) -> T? {
        let operation : (() -> (T?)) = {
            return self.values[targetElementHashValue]
        }
        return self.syncOperation(operation: operation)
    }
    
    /// check wether an element is avaliable in the collection with the passed hash value
    func syncCheckContaines(elementHashValue:Int) -> Bool {
        return syncOperation(operation: {
            return self.values[elementHashValue] != nil
        })
    }
    
    /// check wether the collection is empty
    func syncCheckEmpty() -> Bool {
        return syncOperation(operation: {
            return self.values.isEmpty
        })
    }
    
    
    
    
    
    
    
    
    
    
    /// run the operation synchronously on the queue
    private func syncOperation<T>(operation: ()->(T)) -> T {
        var result : T! = nil
        syncQueue.sync {
            result = operation()
        }
        return result
    }
    
    /// run the operation Asynchronously with a barrier flag to avoid memory crashes 
    private func asyncOperation(operation : @escaping ()->()) -> Void {
        let requestDate = timeStamp
        syncQueue.async(flags : .barrier) { [weak self] in
            guard let container = self , container.timeStamp == requestDate else {return}
            operation()
        }
    }
    
    
}
