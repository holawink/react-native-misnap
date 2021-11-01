
# Issue in POD and xcassets included in libraries:
# https://github.com/CocoaPods/CocoaPods/issues/8122

Pod::Spec.new do |s|
  s.name         = "RNMisnap"
  s.version      = "1.1.1"
  s.summary      = "RNMisnap"
  s.description  = <<-DESC
                  RNMisnap, https://www.miteksystems.com/mobile-capture react-native wrapper aroud native framework.
                   DESC
  s.homepage     = "http://www.wundermanthompson.com"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.source       = { :git => "https://github.com/author/RNMisnap.git", :tag => "master" }

  s.ios.deployment_target = '9.0'
  s.source_files  = 'ios/*.{h,m,swift}','ios/MiSnapSDK/classes/*.{h,m,swift}'
  s.public_header_files = 'ios/*.{h}','ios/MiSnapSDK/classes/*.{h}'
  s.frameworks  = 'UIKit', 'AudioToolbox', 'AVFoundation', 'CoreGraphics', 'CoreMedia', 'CoreVideo', 'MobileCoreServices', 'OpenGLES', 'QuartzCore', 'Security', 'ImageIO'

  # s.resources =  ['ios/MiSnapSDK/resources/*']
  s.vendored_frameworks =
  'ios/MiSnapSDK/ios-arm64_armv7/DaonFaceLiveness.framework', 
  'ios/MiSnapSDK/ios-arm64_armv7/DaonFaceLivenessBlink.framework', 
  'ios/MiSnapSDK/ios-arm64_armv7/DaonFaceQuality.framework', 
  'ios/MiSnapSDK/ios-arm64_armv7/DaonFaceSDK.framework',
  'ios/MiSnapSDK/ios-arm64_armv7/MiSnapFacialCapture.framework',

  'ios/MiSnapSDK/MiSnapBarcodeScanner.framework',
  'ios/MiSnapSDK/MiSnapLiveness.framework',
  'ios/MiSnapSDK/MiSnapSDK.framework',
  'ios/MiSnapSDK/MiSnapSDKCamera.framework',
  'ios/MiSnapSDK/MiSnapSDKMibiData.framework',
  'ios/MiSnapSDK/MiSnapSDKScience.framework',
  'ios/MiSnapSDK/MobileFlow.framework'

  s.requires_arc = true
  s.dependency "React"
  #s.dependency "others"

end
