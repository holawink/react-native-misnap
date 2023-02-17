# react-native-misnap.podspec

require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-misnap"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = package["description"]
  s.homepage     = "https://github.com/holawink/react-native-misnap"
  # brief license entry:
  s.license      = "MIT"
  # optional - use expanded license entry instead:
  # s.license    = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Wink" => "winkdev@holawink.com" }
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/author/RNMisnap.git", :tag => "master" }

  s.source_files = "ios/**/*.{h,c,cc,cpp,m,mm,swift}"
  s.requires_arc = true

  s.dependency "React"
  s.dependency "MiSnap"
  s.dependency "MiSnapUX"
  s.dependency "MiSnapFacialCapture"
  s.dependency "MiSnapFacialCaptureUX"
  # ...
  # s.dependency "..."
end

