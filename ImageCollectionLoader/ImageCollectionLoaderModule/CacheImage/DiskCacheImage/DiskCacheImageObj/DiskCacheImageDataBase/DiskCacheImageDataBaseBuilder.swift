//
//  DiskCacheImageDataBaseBuilder.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 2/11/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation

class DiskCacheImageDataBaseBuilder {
    var dataBaseObjs : Set<PersistentUrl> = []
    var delay : TimeInterval = 0

    
    
    func concrete() -> DiskCacheImageDataBase {
        let database = DiskCacheImageDataBase(path: .defaultPath)
        return database
    }
    
    func concreteForTesting() -> DiskCacheImageDataBase {
        let database = DiskCacheImageDataBase(path: .custom(path: "\(Date().timeIntervalSince1970)"))
        return database
    }
    
    
    func mock() -> DiskCacheImageDataBaseMock {
        return  DiskCacheImageDataBaseMock(delay: delay, dataBaseObjs: dataBaseObjs)
      
    }

    
    
    func with(dataBaseObjs:Set<PersistentUrl> ) -> DiskCacheImageDataBaseBuilder {
        self.dataBaseObjs = dataBaseObjs
        return self
    }
    
    
    func with(delay:TimeInterval) -> DiskCacheImageDataBaseBuilder {
        self.delay = delay
        return self
    }
    
    
    
}
