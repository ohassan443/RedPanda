//
//  TableImageLoaderBuilder.swift
//  Zabatnee
//
//  Created by Omar Hassan  on 2/5/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
public class ImageCollectionLoaderBuilder {
    var imageLoader : ImageLoaderObj = ImageLoaderBuilder().defaultErrorMock()
    var internetChecker : InternetConnectivityCheckerObj = InternetConnectivityCheckerBuilder().Mock()
    var reachability : ReachabilityMOnitorObj = ReachabailityMonitorMock(conncection: .none)
    
    
    public init(){}
    
    public func defaultImp() -> ImageCollectionLoader {
        let imageloader = ImageLoaderBuilder().concrete()
        let internetChecker = InternetConnectivityCheckerBuilder().concrete()
        let reachability = ReachabailityMonitor()
        
        
        let tableImageLoader = ImageCollectionLoader(imageLoader: imageloader, reachability: reachability, connectivityChecker: internetChecker)
        
        reachability.set(delegate: tableImageLoader)
        return tableImageLoader
        
    }
    
    
    
    public func TESTCustomConcrete() -> ImageCollectionLoader {
        return ImageCollectionLoader(imageLoader: imageLoader, reachability: reachability, connectivityChecker: internetChecker)
        
    }
    
    
    
    func mock() -> ImageCollectionLoaderMock {
        return ImageCollectionLoaderMock()
        
    }
    
    
    
    func with(imageLoader:ImageLoaderObj) -> ImageCollectionLoaderBuilder {
        self.imageLoader = imageLoader
        return self
    }
    
    
    
    func with(internetChecker:InternetConnectivityCheckerObj) -> ImageCollectionLoaderBuilder {
        self.internetChecker = internetChecker
        return self
    }
    
    
    
    func with(reachability:ReachabilityMOnitorObj) -> ImageCollectionLoaderBuilder {
        self.reachability = reachability
        return self
    }
    
    
}
