require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))


# Issue in POD and xcassets included in libraries:
# https://github.com/CocoaPods/CocoaPods/issues/8122

Pod::Spec.new do |s|
  s.name         = "RNMisnap"
  s.version      = package['version']
  s.summary      = package['description']
  s.description  = package['description']
  s.homepage     = package['homepage']
  s.license      = package['license']
  s.author       = { "author" => "author@domain.cn" }
  s.source       = { :git => "https://github.com/author/RNMisnap.git", :tag => "master" }

  s.ios.deployment_target = '9.0'
  s.source_files  = 'ios/*.{h,m}','ios/MiSnapSDK/classes/*.{h,m}'
  s.public_header_files = 'ios/*.{h}','ios/MiSnapSDK/classes/*.{h}'
  s.frameworks  = 'UIKit', 'AudioToolbox', 'AVFoundation', 'CoreGraphics', 'CoreMedia', 'CoreVideo', 'MobileCoreServices', 'OpenGLES', 'QuartzCore', 'Security', 'ImageIO'

  # s.resources =  ['ios/MiSnapSDK/resources/*']
  s.vendored_frameworks = 'ios/MiSnapSDK/MiSnap.xcframework',
  'ios/MiSnapSDK/MiSnapBarcodeScanner.xcframework', 
  'ios/MiSnapSDK/MiSnapCamera.xcframework',
  'ios/MiSnapSDK/MiSnapLicenseManager.xcframework',
  'ios/MiSnapSDK/MiSnapMibiData.xcframework',
  'ios/MiSnapSDK/MiSnapScience.xcframework',
  'ios/MiSnapSDK/MobileFlow.xcframework'

  s.requires_arc = true
  s.dependency "React"
  #s.dependency "others"

end
  