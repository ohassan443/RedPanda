//
//  SyncedDic.swift
//  ImageCollectionLoader
//
//  Created by Omar Hassan  on 11/10/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation

class SyncedDic<T: Hashable>{
    var values : [Int:T] = [:]
    private var timeStamp = Date()
    
    let syncQueue =  DispatchQueue(label: "queue", qos: .userInitiated, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: DispatchQueue.global(qos: .userInitiated))
    let completionQueue = DispatchQueue(label: "queue", qos: .userInitiated, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: DispatchQueue.global(qos: .userInitiated))
    
    public func updateTimeStamp()-> Void{
        timeStamp = Date()
    }
    
    func syncedInsert(element: T,completion:  (()->())? = nil  ) -> Void {
        asyncOperation(operation: {
            self.values[element.hashValue] = element
        }, completion:{ response in
            self.completionQueue.async {
                completion?()
            }
        })
    }
    func syncedRemove(element:T,completion: (()->())? = nil) -> Void {
        asyncOperation(operation: {
            self.values[element.hashValue] = nil
        }, completion:{
            self.completionQueue.async {
                completion?()
            }
        })
    }
    func syncedUpdate(element:T,completion: (()->())? = nil) -> Void {
        asyncOperation(operation: {
            self.values[element.hashValue] = element
        }, completion:{ response in
            self.completionQueue.async {
                completion?()
            }
        })
        
        
    }
    
    
    
    func syncedRead(targetElementHashValue:Int) -> T? {
        let operation : (() -> (T?)) = {
            return self.values[targetElementHashValue]
        }
        return self.syncOperation(operation: operation)
    }
    func syncCheckContaines(elementHashValue:Int) -> Bool {
        return syncOperation(operation: {
            return self.values[elementHashValue] != nil
        })
    }
    func syncCheckEmpty() -> Bool {
        return syncOperation(operation: {
            return self.values.isEmpty
        })
    }
    
    
    
    
    
    
    
    
    
    
    
    private func syncOperation<T>(operation: ()->(T)) -> T {
        var result : T! = nil
        syncQueue.sync {
            result = operation()
        }
        return result
    }
    
    private func asyncOperation<U>(operation : @escaping ()->(U),completion: @escaping ((U)->())) -> Void {
        let requestDate = timeStamp
        syncQueue.async(flags : .barrier) { [weak self] in
            guard let container = self , container.timeStamp == requestDate else {return}
            let result = operation()
            completion(result)
        }
    }
    
    
}
