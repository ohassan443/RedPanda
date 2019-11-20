//
//  DiskCacheImageDatabaseMock.swift
//  RedPanda
//
//  Created by Omar Hassan  on 2/11/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import UIKit

class DiskCacheImageDataBaseMock  {
    
    var dataBaseObjs : Set<PersistentUrl>
    var delay : TimeInterval

    
    
    init(delay:TimeInterval,dataBaseObjs:Set<PersistentUrl>){
        self.dataBaseObjs = dataBaseObjs
        self.delay = delay
    }
    
}

extension DiskCacheImageDataBaseMock : DiskCacheDataBaseProtocol {
   
   
    func cache(url: String,completion: @escaping (_ result : Bool)->()) -> Void{
           databaseQueue.asyncAfter(deadline: .now() + delay, execute: {[weak self] in
            guard let mock = self else {return}
            
            let objToSave = PersistentUrl(url: url)
            
            let insert = mock.dataBaseObjs.insert(objToSave)
            
            completion(insert.inserted)

        })
    }
    
    
    
    
    func getImageFor(url:String,completion: @escaping (_ image : UIImage?)->()) -> Void{
           databaseQueue.asyncAfter(deadline: .now() + delay, execute: {[weak self] in
            guard let mock = self else {return}
            
            
            let queryUrl = PersistentUrl.amazonCheck(url: url)
            
            let obj = mock.dataBaseObjs.filter(){
                return  $0.url == queryUrl
                }.first
            
            
            guard let dataBaseObj = obj else {
                completion(nil)
                return
            }
            
            
            dataBaseObj.setLastAccessDate(Date: Date())
            
            mock.dataBaseObjs.update(with: dataBaseObj)

        })
    }
    
    
    
    
    
    func delete(url:String , completion : @escaping (_ result : Bool)->()) -> Void{
           databaseQueue.asyncAfter(deadline: .now() + delay, execute: {[weak self] in
            guard let mock = self else {return}
            
            
            let dataBaseDeleteUrl = PersistentUrl.amazonCheck(url: url)
            
            
            let obj = mock.dataBaseObjs.filter(){
                return  $0.url == dataBaseDeleteUrl
                }.first
            
            
            guard let ObjToDelete = obj  else {
                completion(true)
                return
            }
            
            mock.dataBaseObjs.remove(ObjToDelete)
            completion(true)
            
        })
    }
    
    
    
    func deleteWith(minLastAccessDate:Date,completion:@escaping(_ result:Bool)->()) ->Void {
        databaseQueue.asyncAfter(deadline: .now() + delay, execute: {
            
            
            let dataBaseItems = self.dataBaseObjs.filter(){
                guard let accessDate = $0.getLastAccessDate() else { return false}
                return accessDate < minLastAccessDate
            }
            

            let count = dataBaseItems.count
            
            for (index,item) in dataBaseItems.enumerated() {
                
               self.dataBaseObjs.remove(item)
                
                if index == (count - 1) {
                    completion(true)
                }
            }
        })
        
    }
    
    
    
    func getFileSystemUrlFor(url: String, completion: @escaping (String?) -> ()) {
        
        databaseQueue.asyncAfter(deadline: .now() + delay, execute: {[weak self] in
            
            guard let mock = self else {return}
            
            
            let dataBaseDeleteUrl = PersistentUrl.amazonCheck(url: url)
            
            
            let obj = mock.dataBaseObjs.filter(){
                return  $0.url == dataBaseDeleteUrl
                }.first
            
            
          completion(obj?.getFileSystemName())
            
        })
    }
    
   
    func delete(urls: [String], completion: @escaping (Bool) -> ()) {
        
        databaseQueue.asyncAfter(deadline: .now() + delay, execute: {
            
            let dataBaseUrls = urls.map(){PersistentUrl.amazonCheck(url: $0)}
            
            let dataBaseItems = self.dataBaseObjs.filter(){
                return dataBaseUrls.contains($0.url)
            }
            
            
            let count = dataBaseItems.count
            
            for (index,item) in dataBaseItems.enumerated() {
                
                self.dataBaseObjs.remove(item)
                
                if index == (count - 1) {
                    completion(true)
                }
            }
            
        })
    }
    
    func getUrlsWith(minlastAccessDate: Date, completion: @escaping ([String]) -> ()) {
        
        databaseQueue.asyncAfter(deadline: .now() + delay, execute: {
            
            let dataBaseItems = self.dataBaseObjs.filter(){
                guard let accessDate = $0.getLastAccessDate() else { return false}
                return accessDate < minlastAccessDate
            }
            
            
            let fileSystemUrls : [String] = dataBaseItems.compactMap(){return $0.getFileSystemName()}
            completion(fileSystemUrls)
        })
        
        
    }
  
    
    
    
    
    func deleteDataBase() -> Bool {
        dataBaseObjs.removeAll()
        return true
    }
    
    
}
