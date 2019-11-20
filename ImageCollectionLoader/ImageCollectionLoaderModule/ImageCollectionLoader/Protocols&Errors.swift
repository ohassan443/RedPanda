//
//  Protocols.swift
//  RedPanda
//
//  Created by Omar Hassan  on 2/11/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//


import Foundation
import Reachability



typealias ImageCollectionLoaderRequestCompletionHandler = ( RequestResponse ) -> ()
typealias successparams = RequestResponse.SuccessParams
typealias failparams = RequestResponse.FailParams


enum RequestResponse {
    struct SuccessParams {
        let image       : UIImage
        let date        : Date
        let indexPath   : IndexPath
    }
    struct FailParams {
       var error        : imageLoadingError
       var request      : imageRequest
    }
    
    case success(params:SuccessParams)
    case fail(params: FailParams)
    
    func getIndexPath() -> IndexPath {
        switch self {
        case .success(let params):
            return params.indexPath
        case .fail(let params):
            return params.request.indexPath
        }
    }
}



/**
 
 - Handles sync  cache checking and image corresponding to a url.
 
 
 - Handles  async loading of an url associated with an indexPath, tag and the date the request was made at
    + the indexPath is used to fetch the cell to which binding the image should happend
    + the tag is used to differentiate between urls for the same indexPath -> assuming that the same indexpath may have a card and a logo with the same url
            


 */
public protocol ImageCollectionLoaderProtocol : ReachabilityMonitorDelegateProtocol {
    
  
    /// - parameter interval : the interval after which a retry request will be made in case an internet connectivity error occurs with an avaliable network
     func changeTimerRetry(interval:TimeInterval) -> Void
    
    /**
        - parameter requestDate           : the date the request was made at , so the caller can differentitate between old and new requests
            + for example if the user refreshes the tableview and different data is shown , the caller can differentiate between callBacks from berfore refreshing the table and after using this date
        - parameter url                             : the target url
        - parameter indexPath                : indexPath to return in the successHandler
        - parameter tag                             : a tag so that requests with the same url and indexPath can have different ( success / fail handlers ) in case a cell ( indexpath ) has a card and a logo with the same url
        - parameter successHandler     : the callBack to execute after loading the image successfully
        - parameter failedHandler       : the callBack to execute when loading the image fails due to having nil data as response or the server data cant be parsed to an image
     */
     func requestImage(requestDate : Date
    , url:String
    ,indexPath:IndexPath
    ,tag:String
        ,successHandler:@escaping (_ successImage:UIImage,_ successIndexPath:IndexPath,_ successRequestDate:Date)->()
    ,failedHandler: ((_ failedRequest:imageRequest?,_ image:UIImage?,_ requestState:imageRequest.RequestState.AsynchronousCallBack)->())?
    )-> Void
    
 }


/**
 # - Manages ( read / write / delete / delete all ) images from and to the file system on the device
 
 # - Manages creating the root container directory and deleting all Images
 
 # - Manages deleting certain urls from the file system on the device
 */
internal  protocol DiskCacheFileSystemProtocol {
    /// write and image to the file system , make its name related to its url
    func writeToFile(image:UIImage,url:String, completion: @escaping (_ result : Bool)->())-> Void
    
    /// read image from the file system that corresponds to the passed url
    /// will return nil if there is no image
    func readFromFile(url:String,completion: @escaping (_ image : UIImage?)->())-> Void
    
    /// delete the image from the file system that matches the passed url
    func deleteFromFile(url:String,completion: @escaping (_ result : Bool)->())-> Void
    
    /// delete certain images related to the passed urls from the file system
    func deleteFilesWith(urls:[String],completion: @escaping (_ result : Bool)->())-> Void
    
    /// delete all cached images
    func deleteAll() -> Bool
}



/// # A ram cache where images that were fetched recently wether from the locacl cache of the network will be stored , it will be faster than fetching them from the filesystem
public protocol RamCacheProtocol {
    /// check for an image that corresponds the passed url in the ram cache
    /// this is a step before hitting the disk cache with a request
    func getImageFor(url:String,result :  @escaping  (UIImage?)->()) -> Void
    
    /// after a successfull fetch , wether from the disk cache or the network , this func will be used to save the image to fasten future lookups
    func cache(image:UIImage,url: String,result :  @escaping  (Bool)->()) -> Void
}


/**
 #  - This type is a facade over the database and the fileSystem
 #  - Remark : the database is used as a mid step as the file system look ups are slow and to perform queries such as deleting images that were saved after a certain url
 */
public protocol DiskCacheProtocol {
     /// - searches the database for the file system name corresponding to the requested url and if found, queries the file system with the name
    func getImageFor(url:String,completion: @escaping (_ image : UIImage?)->()) -> Void
    
    /// - after fetching an image from the network generate a file system name and adds it and the url to the local database and writes the image to the file system with the generated name
    func cache(image:UIImage,url: String,completion: @escaping (_ result : Bool)->()) -> Void
    
    /// deletes the image from disk if avaliable and then deletes it from the database if avaliable
    func delete(url:String , completion : @escaping (_ result : Bool)->()) -> Void
     
    ///- deletes all the saved images  (database / file system)
    func deleteAll() -> Bool
    
    
    /// - deletes images that were saved after a certain date by looking them up in the locacl database and then deleting them from the database and the filesystem
    func deleteWith(minLastAccessDate:Date,completion:@escaping(_ result:Bool)->()) ->Void
   
}



/**
 - fetches file system associated with the passed url if avaliable
 */
internal protocol DiskCacheDataBaseProtocol {
    func getFileSystemUrlFor(url:String,completion: @escaping (_ fileSystemUrl : String?)->()) -> Void
    
    /// adds url the data base and the file system name to the database
    func cache(url: String, completion: @escaping (Bool) -> ())
    
    
    /// deletes the database entry for the passed url
    func delete(url: String, completion: @escaping (Bool) -> ()) -> Void
    
    /// delete the database files from the file system
    func deleteDataBase() ->  Bool
    
    /// delete specific urls from the database
    func delete(urls:[String],completion: @escaping (Bool) -> () )
    
    /// queries the database for elements that were last used after the minLastAccessDate
    func getUrlsWith(minlastAccessDate:Date,completion:@escaping(_ urls : [String])-> ()) -> Void
   /// deletes  the elements in the database  that were last used after the minLastAccessDate
    func deleteWith(minLastAccessDate:Date,completion:@escaping(_ result:Bool)->()) ->Void
}

/**
 hold a refrence to a ram cache and a disk cache
 */
public protocol ImageLoaderProtocol {
    /// looks in the ram cache for the image
    func queryRamCacheFor(url:String,result : @escaping (_ : UIImage?)->()) -> Void
    
    /// queries the ram cache then the disk cache and if both fails loades it from the server and then saves it to the ram and disk caches
    func getImageFrom(urlString:String, completion:  @escaping (_ : UIImage)-> (),fail : @escaping (_ url:String,_ error:Error)-> ()) -> Void
}



/// tracks the changes in the reachability state and notifies its delegate
internal protocol ReachabilityMonitorProtocol {
    var  reachabilityMonitorDelegate : ReachabilityMonitorDelegateProtocol? {get}
    func set(delegate:ReachabilityMonitorDelegateProtocol) -> Void
}



/// recieves changes from ReachabilityMOnitorObj after being set as its delegate
public protocol ReachabilityMonitorDelegateProtocol : class {
    func respondToReachabilityChange(reachable:Bool) -> Void
    var connected : Bool {get}
}


/// checks for internet connectivity by binging a server
internal protocol InternetCheckerProtocol {
    func check(completionHandler: @escaping (Bool) -> Void) ->()
}


protocol UrlSessionWrapperProtocol {
      func dataTask(withUrl:String,completionHandler : @escaping (Data?,URLResponse?,Error?)->()) -> URLSessionDataTask?
}


///
public enum imageLoadingError: Error {
    /// failed to parse server data as image
    case imageParsingFailed
    
    /// nil data as response
    case nilData
    
    /// container error for all network errors found in 'ImageLoaderNetworkErrorCodes'
    case networkError
    
}

let ImageLoaderNetworkErrorCodes =  [
     URLError.notConnectedToInternet
    ,URLError.timedOut
    ,URLError.cannotConnectToHost
    ,URLError.cannotLoadFromNetwork
    ,URLError.networkConnectionLost
    ,URLError.callIsActive
]

public func getTempAmazonUrlfrom(url:String) -> String {
    return "http://[::1]:8080/Folder/subFolder/card" + url +  ".jpg?AWSAccessKeyId=asdasdas12323&Expires=1231231234&Signature=asdasdasd"
    //return "https://appName.amazonaws.com/Folder/subFolder/card" + url +  ".jpg?AWSAccessKeyId=asdasdas12323&Expires=1231231234&Signature=asdasdasd"
    
}

