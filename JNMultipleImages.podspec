#
#  Be sure to run `pod spec lint JNMultipleImages.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "JNMultipleImages"
  s.version      = "1.0.0"
  s.summary      = "summery of JNMultipleImages."
  s.description  = 'This is a description for this library'
  s.homepage     = "https://github.com/JNDisrupter"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Jayel Zaghmoutt" => "eng.jayel.z@gmail.com", "Mohammad Nabulsi" => "mohammad.s.nabulsi@gmail.com"   }
  s.ios.deployment_target = '9.0'
  s.source       = { :git => "https://github.com/JNDisrupter/JNMultipleImages.git", :tag => "#{s.version}" }
  s.source_files = "JNMultipleImages/**/*.{swift}"
  s.resources = "JNMultipleImages/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"
  s.framework  = "UIKit"
  s.dependency 'SDWebImage', '~> 4.1.0'
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
end
