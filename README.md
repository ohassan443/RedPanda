# RedPanda
Image loading and caching library for iOS written in Swift

[Features](#Features)  
[Depenedencies](#Depenedencies)  
[Requirments](#Requirments)  
[installation](#installation)  
[Usage](#Usage)  
[License](#License)  
[TODO](#TODO)  



# Features
   * TableViews / collectionViews convience loader :
      - Request hashing with url-indexPath-tag to load images for tableViews and collectionViews 
      - Ignore redundant calls for calls that are currently processing or were processed and are invalid 
      - Retry requests that failed due to network error or internet connectivity error when connection goes back up
      - Timestamping requests to cope with refreshing / updating the collection and to avoid wrong callBacks execution
      
   * Independent components that can be used seperatly :    
        - Disk Caching and Ram Caching 
        - Variable Ram Cache 
        - Image Loader thats has access to the disk cache 
        - Option to delete all disk cached images or images that were accessed after a certain date only 
# Depenedencies 
  * ReachabilitySwift
  * RealmSwift 
  
  
# Requirments
  * iOs 12.0+
  * Xcod 10.1+
  * Swift 4.2+

# Installation
 > Avaliable through CocoaPods  
  ``` pod 'RedPanda' ```
# Usage
```swift
   import ImageCollectionLoader
```
<br/>

* loading images into tableViews or collectionViews
  - __request date__ is a timestamp for when this call was made so the caller can decide wether it is  correct to use the  
     result image (Ex: refreshing tableView or adding/removing rows changes the indexpath to render the image at)  
  - __tag__ is used incase the same indexpath have more than one image with the same url to avoid discard loading the second 
    image (Ex: could be card and logo)   
  - Requesting images from cellForRow is safe as duplicate requests will be discarded (A request is hashed by url & 
    indexPath & tag ) 
  - __FailedState__ 
    + case currentlyLoading : another request with the same indexpath - tag - url was requested and is loading now
    + case invalid : the requested url was loaded before and the parsing of the image failed
    + case processing : the request is being processed
    
```swift
   let imageCollectionLoader = ImageCollectionLoaderBuilder().defaultImp(ramMaxItemsCount: 60)
   imageCollectionLoader.requestImage(requestDate: Date(), url: element, indexPath: indexPath, tag: "card", successHandler:         
   {
                image , index , date in
                guard let visibleCell = tableView.cellForRow(at: index) as? cell else {return}
                visibleCell.iv.image = image
            }, failedHandler: {
               failedRequest,failedImage,requestState in
                print(failedRequest)
                print(failedImage)
                print(requestState)
            })
```
<br/>  

  * loading images separately

```swift
     let imageLoader = ImageLoaderBuilder().concrete(ramMaxItemsCount: 50).getImageFrom(urlString: "testUrl", completion: {
            image in
        }, fail: {
            failMessage , error in 
        })
```

<br/>

# License
  MIT

# TODO
   
  - Make Internet and reachability monitor a seperate component with injectable configuration including
    + max number of tries 
    + retry interval
  - Injectable preprocessing for urls to make timestamping cleaning dynamic 
  - Injectable directory to DiskCache and DiskCacheFileSystem 
  - Make DiskCache generic instead of images only
  - add tests for spamming localServer and multiple instances of ImageCollectionLoader running at once
     
