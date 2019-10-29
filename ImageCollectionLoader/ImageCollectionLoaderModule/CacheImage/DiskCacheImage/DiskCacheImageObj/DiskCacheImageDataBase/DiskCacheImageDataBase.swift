//
//  RealmClient.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 1/30/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import RealmSwift


let databaseQueue = DispatchQueue(label: "realmClientQueue", qos: .userInitiated, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: DispatchQueue.global(qos: .userInitiated))

class DiskCacheImageDataBase  {
    
    enum pathUrl {
        case defaultPath
        case custom(path:String)
    }
    
    
    
    private var path : pathUrl = .defaultPath
    private var config: Realm.Configuration {
        switch path {
        case .defaultPath:
            return Realm.Configuration.defaultConfiguration
            
        case .custom(path: let customPath):
            var customConfig = Realm.Configuration()
            customConfig.fileURL = customConfig.fileURL!.deletingLastPathComponent().appendingPathComponent("\(customPath).realm")
            return customConfig
        }
    }
    
    
    init(path:pathUrl) {
        self.path = path
    }
  
    private func createRealm() -> Realm {
        if let realm = try? Realm(configuration: config){
            return realm
        }
        
        let _ = self.deleteDataBase()
        return try! Realm(configuration: config)
    }
}
extension DiskCacheImageDataBase : DiskCacheImageDataBaseObj {
 
    
    func cache(url: String,completion: @escaping (_ result : Bool)->()) -> Void{
        databaseQueue.async(flags:.barrier){ [weak self] in
            guard let database = self else {return}
            
            let objToSave = PersistentUrl(url: url)
            
            let realm  = database.createRealm()
            let cache : ()? = try? database.createRealm().write {
                realm.add(objToSave,update: true)
            }
            
            let addResult  =  cache != nil
            completion(addResult)
            
            
        }
    }
    
    
    
    
    func getFileSystemUrlFor(url:String,completion: @escaping (_ fileSystemUrl : String?)->()) -> Void{
        databaseQueue.async { [weak self] in
            guard let database = self else {return}
            
            let queryUrl = PersistentUrl.amazonCheck(url: url)
            
           let realm = database.createRealm()
           guard let realmObj = realm.objects(PersistentUrl.self).filter("url == %@",queryUrl).first , let fileSystemName = realmObj.getFileSystemName() else {
                completion(nil)
                return
            }
            
            let _ : ()? = try? realm.write {
                realmObj.setLastAccessDate(Date: Date())
            }
            completion(fileSystemName)
            
        }
    }
    
    
    
    
    
    func delete(url: String, completion: @escaping (Bool) -> ()) -> Void{
        databaseQueue.async (flags:.barrier){ [weak self] in
            guard let database = self else {return}
            
            let realmDeleteUrl = PersistentUrl.amazonCheck(url: url)
            
            guard let obj = database.createRealm().objects(PersistentUrl.self).filter("url == %@",realmDeleteUrl).first else {
                completion(true)
                return
            }
            
            
            
            let realmDelete : ()? =  try? database.createRealm().write {
                database.createRealm().delete(obj)
            }
            
            let result = realmDelete != nil
            completion(result)
         }
    }
    
    func getUrlsWith(minlastAccessDate: Date, completion: @escaping ([String]) -> ()) {
        let database = createRealm()
        let dataBaseItems = (database.objects(PersistentUrl.self).filter("lastAccessDate <= %@", minlastAccessDate))
        
        let urls : [String] = dataBaseItems.compactMap(){return $0.getFileSystemName()}
    
        completion(urls)
        
    
       
            
        }


    func delete(urls: [String], completion: @escaping (Bool) -> ()) {
        
        let dataBaseUrls = urls.map(){PersistentUrl.amazonCheck(url: $0)}
        
        var deletedAllSuccessfully = true
        
        databaseQueue.async (flags:.barrier){
            let database = self.createRealm()
            for (index,url) in dataBaseUrls.enumerated() {
                
                guard let item = database.objects(PersistentUrl.self).filter("url == %@",url ).first else {
                    continue
                }
                
                
                
                do{
                    try database.write {
                        database.delete(item)
                    }
                }catch{
                    //print(error)
                    deletedAllSuccessfully = false
                }
                if index == urls.count - 1 {
                    completion(deletedAllSuccessfully)
                }
            }
        }
    }
    
    
    
    
    func deleteWith(minLastAccessDate:Date,completion:@escaping(_ result:Bool)->()) ->Void {
        
        databaseQueue.async( flags: .barrier, execute: {
            let database = self.createRealm()
            let dataBaseItems = database.objects(PersistentUrl.self).filter("lastAccessDate <= %@", minLastAccessDate)
            
            
            var deletedItemsSuccessfully = false
            let count = dataBaseItems.count
            for (index,item) in dataBaseItems.enumerated() {
                
                let innerIndex = index
                
                do{
                    try database.write {
                        database.delete(item)
                    }
                }catch{
                    //print(error)
                    deletedItemsSuccessfully = false
                }
                
                
                if innerIndex == (count - 1) {
                    completion(deletedItemsSuccessfully)
                }
            }
            
        })
    }

    
   
    
    func deleteDataBase() -> Bool {
        let realmUrl = config.fileURL!
        
        let lockFileUrl = realmUrl.appendingPathExtension("lock")
        
        
        let managmentFileUrl = realmUrl.appendingPathExtension("management")
        
        do{
            try FileManager.default.removeItem(at: lockFileUrl)
             try FileManager.default.removeItem(at: managmentFileUrl)
        }catch{
            //print(error)
        }
    
        
        
        let realmDeleteResult : ()? = try? FileManager.default.removeItem(at: realmUrl)
        
        return realmDeleteResult != nil
    }
    
}
