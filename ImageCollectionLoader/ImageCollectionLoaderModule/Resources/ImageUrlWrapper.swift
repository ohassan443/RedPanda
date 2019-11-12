//
//  ImageUrlWrapper.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 1/30/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import UIKit




/**
 object to use as container in the mocks
 */
struct ImageUrlWrapper : Hashable {
    var image : UIImage?
    var url : String
    var lastAccessDate :Date
    
    init(url:String,image:UIImage? = nil) {
        self.image = image
        self.url = url
        self.lastAccessDate = Date()
    }
    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(url)
//    }
    var hashValue: Int {
       return self.url.hashValue
    }
    
    static func == (lhs: ImageUrlWrapper, rhs: ImageUrlWrapper) -> Bool {
        return lhs.url == rhs.url
    }
    
    static func setContaints(set:Set<ImageUrlWrapper>,url:String) -> ImageUrlWrapper? {
        let result = set.first(where: {$0.url == url})
        return result
    }
    
    mutating func set(lastAccessDate:Date) -> Void {
        self.lastAccessDate = lastAccessDate
    }
    func getLastAccessDate() -> Date {
        return lastAccessDate
    }
    
}
