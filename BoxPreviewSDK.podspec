Pod::Spec.new do |spec|
  spec.name         = "BoxPreviewSDK"
  spec.version      = "3.3.0"
  spec.summary      = "Box Preview SDK"
  spec.description  = <<-DESC
  This SDK makes it easy to present Box files.
                   DESC
  spec.homepage     = "https://github.com/box/box-ios-preview-sdk"
  spec.license      = "Apache License, Version 2.0"
  spec.author             = { "Box" => "sdks@box.com" }
  spec.social_media_url   = "https://twitter.com/box"
  spec.ios.deployment_target = "11.0"
  spec.source       = { :git => "https://github.com/box/box-ios-preview-sdk.git", :tag => "v"+spec.version.to_s }
  spec.swift_versions = ["5.0", "5.1", "5.2", "5.3", "5.4"]
  spec.requires_arc = true
  spec.dependency "BoxSDK", "~> 5.0"

  spec.default_subspec = "Core"
  spec.subspec "Core" do |ss|
      ss.source_files  = "Sources/**/*.swift"
      ss.frameworks  = "Foundation", "UIKit", "PDFKit"
  end
end
