//
//  FileSystemImageCache.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 2/8/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import UIKit

/// the queue is global for all instances of the file system so that if multiple instances are accessing the same file (all instances of this class will refere to the same file)
  let fileSystemQueue = DispatchQueue(label: "fileSystemQueue", qos: .userInitiated, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: DispatchQueue.global(qos: .userInteractive))

class FileSystemImageCache: FileSystemImageCacheObj {
   
    
    
    
    private var directory : URL
    private var retryingAfterCreateFolder = false
   
    
    
    init(directory : URL) {
        self.directory = directory
    }
    
    /**
     write the image as data in the filder and if the folder doesnot exist (first run) then create it and write the image
     */
    func writeToFile(image: UIImage, url: String, completion: @escaping (Bool) -> ()) {
        fileSystemQueue.async (flags:.barrier){[weak self] in
            guard let filesSystem = self else {return}
            let fileURL = filesSystem.directory.appendingPathComponent(url)
            // get your UIImage jpeg data representation
            guard let data = image.pngData() else {
                completion(false)
                return
                
            }
            
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
                completion(true)
                return
            } catch {
                //print("error saving file:", error)
                guard filesSystem.retryingAfterCreateFolder == false else {
                    completion(false)
                    return
                }
                if  (error as! NSError).code == NSFileNoSuchFileError {
                    filesSystem.createImagesDirectoryIfNoneExists()
                    fileSystemQueue.asyncAfter(deadline: .now() + 1, execute: {
                        filesSystem.writeToFile(image: image, url: url, completion: completion)
                    })
                }else {
                       completion(false)
                }
            }
        }
    }

    
    
    
    
    
    /// read data from file if found and parse it to an image
    func readFromFile(url: String, completion: @escaping (UIImage?) -> ()) {
        fileSystemQueue.async {[weak self] in
            guard let filesSystem = self else {return}
            let fileToRead = filesSystem.directory.appendingPathComponent(url)
            
            
            guard let imageData = try? Data(contentsOf: fileToRead)
                ,let image = UIImage(data: imageData)
                else {
                    completion(nil)
                    return
            }
            completion(image)
        }
    }
    
    
    /// delete image data from file
    func deleteFromFile(url: String, completion: @escaping (Bool) -> ()) {
        fileSystemQueue.async(flags:.barrier) {[weak self] in
            guard let filesSystem = self else {return}
            let fileToDelete = filesSystem.directory.appendingPathComponent(url)
            let delete : ()? = try? FileManager.default.removeItem(at: fileToDelete)
            
            let deleteResult = delete != nil
            completion(deleteResult)
        }
    }
    
    /// delete images data from file matching the passed names
    func deleteFilesWith(urls: [String], completion: @escaping (Bool) -> ()) {
        fileSystemQueue.async (flags:.barrier){
            var deletedAll = true
            urls.forEach(){
                let fileToDelete = self.directory.appendingPathComponent($0)
                let delete : ()? = try? FileManager.default.removeItem(at: fileToDelete)
                
                let deleteResult = delete != nil
                deleteResult == false ? (deletedAll = false) : ()
            }
             completion(deletedAll)
        }
    }
    
    
    /// create the image directory
    func createImagesDirectoryIfNoneExists() {
      
            let imagesPath = directory
            
            
            do{
                try FileManager.default.createDirectory(atPath: imagesPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
        
    }
    
    
    
    
    
    /// delete the directory with all of its contained images
    func deleteAll() -> Bool {
        let deleteFilesResult : ()? = try? FileManager.default.removeItem(at: directory)
        return deleteFilesResult != nil
        
    }
    
}
