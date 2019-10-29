//
//  Protocols.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 2/11/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//


import Foundation
import Reachability


protocol imageLoaderUser {
    var requestDate:Date {get set}
    var imageCollectionLoader : ImageCollectionLoaderObj! {get set}
    func requestImages(currentCell:UITableViewCell,indexPath:IndexPath) -> Void
    func requestImages(currentCell:UICollectionViewCell,indexPath:IndexPath) -> Void
}
extension imageLoaderUser {
    func requestImages(currentCell:UITableViewCell,indexPath:IndexPath) -> Void {}
    func requestImages(currentCell:UICollectionViewCell,indexPath:IndexPath) -> Void{}
}



protocol ImageCollectionLoaderObj : ReachabilityMonitorDelegate {
    typealias params = ( success : Bool,image : UIImage? , dateRequestedAt:Date , indexPath : IndexPath,failedRequest : imageRequest?,error:imageLoadingError?)
    typealias cellCompletionHandler = (_ image: UIImage?,_ indexPath:IndexPath)-> ()
    
    func cacheQueryState(url:String) -> (state:imageRequest.RequestState,image:UIImage?)
  
    func changeTimerRetry(interval:TimeInterval) -> Void
    
    func requestImage(requestDate : Date
    , url:String
    ,indexPath:IndexPath
    ,tag:String
    ,successHandler:@escaping (_ image:UIImage,_ indexPath:IndexPath,_ requestDate:Date)->()
    ,failedHandler: ((_ failedRequest:imageRequest,_ image:UIImage?)->())?
        )-> imageRequest.RequestState
    
 }



protocol FileSystemImageCacheObj {
    
    func writeToFile(image:UIImage,url:String, completion: @escaping (_ result : Bool)->())-> Void
    
    func readFromFile(url:String,completion: @escaping (_ image : UIImage?)->())-> Void
    
    func deleteFromFile(url:String,completion: @escaping (_ result : Bool)->())-> Void
    
    func deleteFilesWith(urls:[String],completion: @escaping (_ result : Bool)->())-> Void
    
    func createImagesDirectoryIfNoneExists() -> Void
    
    func deleteAll() -> Bool
}




protocol RamCacheImageObj {
    func getImageFor(url:String) -> UIImage?
    func cache(image:UIImage,url: String) -> Bool
}

protocol DiskCahceImageObj {
    func getImageFor(url:String,completion: @escaping (_ image : UIImage?)->()) -> Void
    func cache(image:UIImage,url: String,completion: @escaping (_ result : Bool)->()) -> Void
    func delete(url:String , completion : @escaping (_ result : Bool)->()) -> Void
    func createImagesDirectoryIfNoneExists() -> Void
    func deleteAll() -> Bool
    func deleteWith(minLastAccessDate:Date,completion:@escaping(_ result:Bool)->()) ->Void
   
}

protocol DiskCacheImageDataBaseObj {
    func getFileSystemUrlFor(url:String,completion: @escaping (_ fileSystemUrl : String?)->()) -> Void
    func cache(url: String, completion: @escaping (Bool) -> ())
    func delete(url: String, completion: @escaping (Bool) -> ()) -> Void
    func deleteDataBase() ->  Bool
    func delete(urls:[String],completion: @escaping (Bool) -> () )
    func getUrlsWith(minlastAccessDate:Date,completion:@escaping(_ urls : [String])-> ()) -> Void
    func deleteWith(minLastAccessDate:Date,completion:@escaping(_ result:Bool)->()) ->Void
}

protocol ImageLoaderObj {
    func queryRamCacheFor(url:String) -> UIImage?
    func getImageFrom(urlString:String, completion:  @escaping (_ : UIImage)-> (),fail : @escaping (_ url:String,_ error:Error)-> ()) -> Void
}




protocol ReachabilityMOnitorObj {
    var  reachabilityMonitorDelegate : ReachabilityMonitorDelegate? {get}
    func set(delegate:ReachabilityMonitorDelegate) -> Void
}




protocol ReachabilityMonitorDelegate : class {
    func respondToReachabilityChange(reachable:Bool) -> Void
    var connected : Bool {get}
}



protocol InternetConnectivityCheckerObj {
    func check(completionHandler: @escaping (Bool) -> Void) ->()
}


protocol PingObj {
    func ping(url:String ,result : @escaping (PingResult)->()) -> Void
}


enum imageLoadingError: Error {
    case imageParsingFailed
    case invalidResponse
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

func getTempAmazonUrlfrom(url:String) -> String {
    return "https://appName.amazonaws.com/Folder/subFolder/card" + url +  ".jpg?AWSAccessKeyId=A!@£$%124123123&Expires=1231231234&Signature=sadfsadfsadfs123@£$%^&^*(*(^*(^*(%3D"
}

