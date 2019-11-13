Pod::Spec.new do |s|

## 1
s.platform = :ios
s.ios.deployment_target = '12.0'
s.name = "ImageCollectionLoader"
s.summary = "like loades images"
s.requires_arc = true

# 2
s.version = "0.1.12"

s.summary = <<-DESC 
description
 DESC


# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "omar hassan" => "ohassan443@gmail.com" }

# 5 - Replace this URL with your own GitHub page's URL (from the address bar)
s.homepage = "https://github.com/ohassan443/ImageCollectionLoader"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/ohassan443/ImageCollectionLoader.git", 
             :tag => "#{s.version}" }

# 7
s.framework = "UIKit"
s.dependency 'ReachabilitySwift' , '~> 4.3.0'
s.dependency 'RealmSwift'


# 8
s.source_files = "ImageCollectionLoader/**/*.{swift}"

# 9
s.resources = "ImageCollectionLoader/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

# 10
s.swift_version = "4.2"

end
