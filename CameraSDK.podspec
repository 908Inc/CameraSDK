Pod::Spec.new do |s|

  s.name         = "CameraSDK"
  s.version      = "0.0.2"
  s.summary      = "An easy to use lib for integrating Stories into your app"

  s.description  = <<-DESC
  Fast and convenient way of adding cool Stories into your app. See screenshots for more detail
                   DESC

  s.homepage     = "https://github.com/908Inc/CameraSDK"

  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }

  s.author  = { "908 Inc." => "vz@908.dp.ua" }

  s.platform     = :ios, '8.0'

  s.source = { :git => "https://github.com/908Inc/CameraSDK.git", :tag => "0.0.1" }
  s.source_files  = "src/*"
  s.resources = "res/*"
  

  s.dependency "SAMKeychain"
  s.dependency "MD5Digest"
  s.dependency "SDWebImage"
  s.dependency "MBProgressHUD"

end
