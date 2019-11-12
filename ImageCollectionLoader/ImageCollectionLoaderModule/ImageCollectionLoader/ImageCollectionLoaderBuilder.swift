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
    var internetChecker : InternetCheckerProtocol = InternetConnectivityCheckerBuilder().Mock()
    var reachability : ReachabilityMonitorProtocol = ReachabailityMonitorMock(conncection: .none)
    
    
    public init(){}
    
    public func defaultImp(ramMaxItemsCount:Int) -> ImageCollectionLoaderProtocol {
        let imageloader = ImageLoaderBuilder().concrete(ramMaxItemsCount: ramMaxItemsCount)
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
    
    
    
    func with(internetChecker:InternetCheckerProtocol) -> ImageCollectionLoaderBuilder {
        self.internetChecker = internetChecker
        return self
    }
    
    
    
    func with(reachability:ReachabilityMonitorProtocol) -> ImageCollectionLoaderBuilder {
        self.reachability = reachability
        return self
    }
    
    
}
