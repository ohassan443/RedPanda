//
//  ImageLoaderServer.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 1/30/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import UIKit


class ImageLoader : ImageLoaderObj{
    
    private var  diskCache: DiskCahceImageObj
    private var ramCache: RamCacheImageObj
    
    init(diskCache:DiskCahceImageObj,ramCache:RamCacheImageObj) {
        self.ramCache = ramCache
        self.diskCache = diskCache
    }
    
    
    func queryRamCacheFor(url:String) -> UIImage? {
        let image = ramCache.getImageFor(url: url)
        return image
    }
    
    
    
    
    
    private func cacheToRam(image:UIImage,url:String)-> Bool{
        let urlToCache = PersistentUrl.amazonCheck(url: url)
        let cacheResult = ramCache.cache(image: image, url: urlToCache)
        return cacheResult
    }
    
    
    
    
    func getImageFrom(urlString:String, completion:  @escaping (_ : UIImage)-> (),fail : @escaping (_ url:String,_ error:Error)-> ()) -> Void {
        

        DispatchQueue.main.async {
            [weak self] in
            guard let imageLoader = self else {return}
            
            
            let ramCacheUrl = PersistentUrl.amazonCheck(url: urlString)
            if let ramCachedImage = imageLoader.ramCache.getImageFor(url: ramCacheUrl){
                completion(ramCachedImage)
                return
            }
            
            imageLoader.diskCache.getImageFor(url: urlString, completion: {
                diskCacheImage in
                
                if let image = diskCacheImage {
                  let _ = imageLoader.cacheToRam(image: image, url: ramCacheUrl)
                    DispatchQueue.main.async {
                        completion(image)
                    }
                    return
                }
                
                imageLoader.loadFromServer(urlString: urlString, completion: completion, fail: fail)
            })
        }
    }
    
    
    
    
    private func loadFromServer(urlString:String, completion:  @escaping (_ : UIImage)-> (),fail : @escaping (_ url:String,_ error:Error)-> ()) -> Void {
        
        guard let url = URL(string: urlString) else{return}
        DispatchQueue.global().async {
            let session = imageLoaderUrlSession.getSession()
            
            /*
             // this session is used for testing
             let config = URLSessionConfiguration.default
             config.timeoutIntervalForResource = 60
             config.timeoutIntervalForRequest = 60
             config.requestCachePolicy = .reloadIgnoringCacheData
             let tempSession = URLSession(configuration: config)
             */
            session.dataTask(with: url, completionHandler: { [weak self](data, response, error) -> Void in
                guard let _ = self else {return}
                DispatchQueue.main.async { [weak self] in
                    guard let imageLoader = self else {return}
                    guard error == nil  else {
                        fail(urlString,error!)
                        return
                    }
                    
                    guard let data = data else{
                        fail(urlString,imageLoadingError.invalidResponse)
                        return
                    }
                    guard let resultImage = UIImage(data: data) else {
                        fail(urlString,imageLoadingError.imageParsingFailed)
                        return
                    }
                    
                    let cacheResult = imageLoader.cacheToRam(image: resultImage, url: urlString)
                    imageLoader.diskCache.cache(image: resultImage, url: urlString, completion: {_ in})
                    
                    completion(resultImage)
                    
                }
                
            }).resume()
            
        }
        
    }
    
    
}
