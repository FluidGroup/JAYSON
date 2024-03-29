#
# Be sure to run `pod lib lint JAYSON.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name = "JAYSON"
  s.version = "2.4.0"
  s.summary = "Strict and Scalable JSON library"
  s.homepage = "https://github.com/muukii/JAYSON"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "muukii" => "muukii.app@gmail.com" }
  s.source = { :git => "https://github.com/muukii/JAYSON.git", :tag => s.version.to_s }
  s.social_media_url = "https://twitter.com/muukii0803"
  s.ios.deployment_target = "8.0"
  s.watchos.deployment_target = "2.0"
  s.osx.deployment_target = "10.9"
  s.tvos.deployment_target = "9.0"
  s.swift_versions = ["5.3", "5.4"]
  s.source_files = "Sources/JAYSON/**/*.swift"
end
