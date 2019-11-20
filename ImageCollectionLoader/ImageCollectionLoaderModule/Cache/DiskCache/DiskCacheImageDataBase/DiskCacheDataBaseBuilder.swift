//
//  DiskCacheImageDataBaseBuilder.swift
//  RedPanda
//
//  Created by Omar Hassan  on 2/11/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation

class DiskCacheDataBaseBuilder {
    var dataBaseObjs : Set<PersistentUrl> = []
    var delay : TimeInterval = 0

    
    
    func concrete() -> DiskCacheDataBase {
        let database = DiskCacheDataBase(path: .defaultPath)
        return database
    }
    
    func concreteForTesting() -> DiskCacheDataBase {
        let database = DiskCacheDataBase(path: .custom(path: "\(Date().timeIntervalSince1970)"))
        return database
    }
    
    
    func mock() -> DiskCacheImageDataBaseMock {
        return  DiskCacheImageDataBaseMock(delay: delay, dataBaseObjs: dataBaseObjs)
      
    }

    
    
    func with(dataBaseObjs:Set<PersistentUrl> ) -> DiskCacheDataBaseBuilder {
        self.dataBaseObjs = dataBaseObjs
        return self
    }
    
    
    func with(delay:TimeInterval) -> DiskCacheDataBaseBuilder {
        self.delay = delay
        return self
    }
    
    
    
}
