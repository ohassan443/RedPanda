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
