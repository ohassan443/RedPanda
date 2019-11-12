//
//  PersistenetImage.swift
//  Zabatnee
//
//  Created by omarHassan on 1/23/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit



/**
 Container object for an image in the database
 */
@objcMembers class PersistentUrl: Object {
    /// the server url  stripped of time stamp
    dynamic var url : String = ""
    /// the name of the image on the file system folder
    @objc private dynamic var fileSystemName: String? = nil
    /// the last date this image was fetched
    @objc private dynamic  var lastAccessDate : Date? = nil
    
    
    convenience init (url:String){
        self.init()
        /// remove the time stamp from the url 
        let modifiedUrl = PersistentUrl.amazonCheck(url: url)
        
        self.url = modifiedUrl
        self.fileSystemName = "\(modifiedUrl.hashValue)"
        self.lastAccessDate = Date()
    }
    
    override static func primaryKey() -> String? {
        return "url"
    }
    
    
    func setLastAccessDate(Date:Date) -> Void {
        lastAccessDate = Date
    }
    
    func getLastAccessDate() -> Date? {
        return lastAccessDate
    }
    func getFileSystemName() -> String? {
        return fileSystemName
    }
    
    static func amazonCheck(url:String) -> String {
        var modifiedUrl = url
        
        guard modifiedUrl.contains("?") else {return modifiedUrl}
        
        modifiedUrl = discardAmazonAccessKey(url: modifiedUrl)
        return  modifiedUrl
    }
    static func discardAmazonAccessKey(url:String) -> String {
        let modifiedUrl = String(url.split(separator: "?").first ?? "")
        return modifiedUrl
    }
}





