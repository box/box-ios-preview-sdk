Pod::Spec.new do |s|
 s.name = 'BoxPreviewSDK'
 s.version = '0.0.1'
 s.license = 'Apache License, Version 2.0'
 s.summary = 'This SDK makes it easy to present Box files in your iOS application.'
 s.homepage = 'https://www.box.com'
 s.social_media_url = 'https://twitter.com/box'
 s.authors = { "Box Inc" => "oss@box.com" }
 s.source = { :git => "git@github.com:box/box-swift-preview-sdk.git", :tag => "v"+s.version.to_s }
 s.platforms = { :ios => "11.0" }
 s.requires_arc = true
 s.dependency "BoxSDK"
 s.swift_version = '5.0'

 s.default_subspec = "Core"
 s.subspec "Core" do |ss|
     ss.source_files  = "Sources/**/*.swift"
     ss.framework  = "Foundation"
 end
end
