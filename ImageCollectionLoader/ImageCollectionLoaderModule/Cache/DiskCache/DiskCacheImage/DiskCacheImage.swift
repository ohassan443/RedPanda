//
//  ObjectMapper.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 1/28/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import UIKit

 
/**
#  - This type is a concrete facade over the database and the fileSystem
#  - Remark : the database is used as a mid step as the file system look ups are slow and to perform queries such as  images that were saved after a certain url and get their file system name and delete them
*/
class DiskCacheImage : DiskCacheProtocol {
    /// the database to hold the url and its associated name on the file system
    private var database : DiskCacheDataBaseProtocol
    
    /// an object to store / retreieve images from the disk
    private var fileSystem : DiskCacheFileSystemProtocol
    
    init(DisckCacheImageDatabase:DiskCacheDataBaseProtocol,fileSystemImacheCache:DiskCacheFileSystemProtocol) {
        self.database = DisckCacheImageDatabase
        self.fileSystem = fileSystemImacheCache
    }
    
    
    
    /**
     - check wether the image is in the database first and get its file system name if avaliable and then loaded it from the file system
     - the data is store on the file system instead inside the database as  data to avoid bloating app size
     */
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
     - wtire the image as data to file system then if successfull writes the url & the image file name on the disk to database
     - captures strong self in the fileSystem completion handler to make sure that files on systme have matching entry in database to avoid writing to the filesystem and not updating the database if the object is deallocated
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
     - get the name of the image on the file system and then delete it from the disk and if successfull delete it from the database
     - getting fileSystemUrl captures weak self , but once its completed deleting from fileUrl & database captures strong self
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
    
    /**
     delete images that were last accessed before  a certain data
     */
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
    
    /// delete all images
    func deleteAll() -> Bool {
        let databaseDelete =  database.deleteDataBase()
        let fileSystemDelete = fileSystem.deleteAll()
        return databaseDelete && fileSystemDelete
    }
    
 }



