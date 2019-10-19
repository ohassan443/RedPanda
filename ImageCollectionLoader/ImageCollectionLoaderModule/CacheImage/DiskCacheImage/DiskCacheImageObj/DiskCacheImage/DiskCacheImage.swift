//
//  ObjectMapper.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 1/28/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import UIKit

 

class DiskCacheImage : DiskCahceImageObj {
    
    private var database : DiskCacheImageDataBaseObj
    private var fileSystem : FileSystemImageCacheObj
    
    init(DisckCacheImageDatabase:DiskCacheImageDataBaseObj,fileSystemImacheCache:FileSystemImageCacheObj) {
        self.database = DisckCacheImageDatabase
        self.fileSystem = fileSystemImacheCache
    }
    
    
    
    
    func getImageFor(url: String, completion: @escaping (UIImage?) -> ()) -> Void{
        
        database.getFileSystemUrlFor(url: url, completion: {[weak self]
            fileSystemUrl in
            guard let diskCache = self
                , let fileUrl = fileSystemUrl else {
                    completion(nil)
                    return
            }
            diskCache.fileSystem.readFromFile(url: fileUrl, completion: {
                image in
                completion(image)
            })
        })
        
    }
    
    
    
    /**
     - wtire to file system then if successfull writes to database
     - captures strong self in the fileSystem completion handler to make sure that files on systme have matching entry in database
     */
    func cache(image: UIImage, url: String, completion: @escaping (Bool) -> ())-> Void {
        let objToSave = PersistentUrl(url: url)
        guard let fileSystemUrl = objToSave.getFileSystemName() else {return}
        
        fileSystem.writeToFile(image: image, url: fileSystemUrl, completion: {
            success in
            
           
            guard success == true else {
                completion(false)
                return
            }
            self.database.cache(url: url, completion: {
                dataBaseResult in
                completion(dataBaseResult)
            })
            
        })
    }
    
    
    /**
     getting fileSystemUrl captures weak self , but once its completed deleting from fileUrl & database captures strong self
     */
    
    func delete(url: String, completion: @escaping (Bool) -> ()) -> Void {
        
        
        database.getFileSystemUrlFor(url: url, completion: {[weak self]
            fileSystemUrl in
            guard let diskCache = self ,let fileUrl = fileSystemUrl else {
                completion(false)
                return
            }
            
            diskCache.fileSystem.deleteFromFile(url: fileUrl, completion: {
                fileSystemDeleteResult in
                guard fileSystemDeleteResult == true else {
                    completion(false)
                    return
                }
                diskCache.database.delete(url: url, completion: {
                    databaseDelete in
                    completion(databaseDelete)
                    
                })
                
            })
        })
    }
    
    func createImagesDirectoryIfNoneExists() {
        fileSystem.createImagesDirectoryIfNoneExists()
    }
    
    
    func deleteWith(minLastAccessDate: Date, completion: @escaping (Bool) -> ()) {
        database.getUrlsWith(minlastAccessDate: minLastAccessDate, completion: {
            urls in
            self.fileSystem.deleteFilesWith(urls: urls, completion: {
                fileSystemDelete in
                guard fileSystemDelete == true else {return}
                self.database.deleteWith(minLastAccessDate: minLastAccessDate, completion: {
                    databaseDeleteResult in
                    completion(databaseDeleteResult)
                })
            })
        })
     }
    
    
    func deleteAll() -> Bool {
        let databaseDelete =  database.deleteDataBase()
        let fileSystemDelete = fileSystem.deleteAll()
        return databaseDelete && fileSystemDelete
    }
    
 }



