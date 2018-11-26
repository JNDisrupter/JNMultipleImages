Pod::Spec.new do |s|
  s.name         = "JNMultipleImages"
  s.version      = "2.0.1"
  s.summary      = "summery of JNMultipleImages."
  s.description  = 'Library for multiple images in one container view like facebook posts.'
  s.homepage     = "https://github.com/JNDisrupter"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Jayel Zaghmoutt" => "eng.jayel.z@gmail.com", "Mohammad Nabulsi" => "mohammad.s.nabulsi@gmail.com"   }
  s.ios.deployment_target = '9.0'
  s.source       = { :git => "https://github.com/JNDisrupter/JNMultipleImages.git", :tag => "#{s.version}" }
  s.source_files = "JNMultipleImages/**/*.{swift}"
  s.resources = "JNMultipleImages/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"
  s.framework  = "UIKit"
  s.dependency 'SDWebImage','~> 4.4.2'
  s.screenshots  = [ 'https://github.com/JNDisrupter/JNMultipleImages/raw/master/Images/JNMultipleImages1.gif','https://github.com/JNDisrupter/JNMultipleImages/raw/master/Images/JNMultipleImages2.gif','https://github.com/JNDisrupter/JNMultipleImages/raw/master/Images/JNMultipleImages3.gif','https://github.com/JNDisrupter/JNMultipleImages/raw/master/Images/JNMultipleImages4.gif','https://github.com/JNDisrupter/JNMultipleImages/raw/master/Images/JNMultipleImages5.gif']
end
