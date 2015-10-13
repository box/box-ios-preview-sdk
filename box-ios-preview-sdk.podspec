Pod::Spec.new do |s|

# Root specification

s.name                  = "box-ios-preview-sdk"
s.version               = "1.0.1"
s.summary               = "iOS Preview SDK."
s.homepage              = "https://github.com/box/box-ios-preview-sdk"
s.license               = { :type => "Box Software Development Kit License Agreement", :file => "LICENSE" }
s.author                = "Box"
s.source                = { :http => 'https://raw.githubusercontent.com/box/box-ios-preview-sdk/v1.0.1/box-ios-preview-sdk.zip' }

# Platform

s.ios.deployment_target = "7.0"

# File patterns

s.ios.source_files        = "BoxPreviewSDK.framework/Versions/A/Headers/**/*.h"
s.ios.vendored_frameworks = 'BoxPreviewSDK.framework'
s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(inherited)' }
s.preserve_paths = 'BoxPreviewSDK.framework', 'LICENSE'


# Build settings
s.requires_arc          = true
s.ios.header_dir        = "BoxPreviewSDK"

s.dependency              'box-ios-sdk'

s.resource_bundle = {
  'BoxPreviewSDKResources' => [
     'BoxPreviewSDK.framework/BoxPreviewSDKResources/MDWebView.bundle',
     'BoxPreviewSDK.framework/BoxPreviewSDKResources/*Images/*.*',
     'PSPDFKit.bundle'
  ]
}

s.library       = 'z', 'sqlite3', 'xml2', 'c++'
s.xcconfig      = {'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
s.frameworks    = 'QuartzCore', 'CoreText', 'CoreMedia', 'MediaPlayer', 'AVFoundation', 'ImageIO', 'MessageUI',
                  'CoreGraphics', 'Foundation', 'CFNetwork', 'MobileCoreServices', 'SystemConfiguration',
                  'AssetsLibrary', 'Security', 'UIKit', 'AudioToolbox', 'QuickLook', 'CoreTelephony', 'Accelerate', 'JavaScriptCore', 'GLKit', 'OpenGLES', 'CoreImage'

end
