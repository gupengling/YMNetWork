#
# Be sure to run `pod lib lint YMPodPrivateNetWork.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YMPodPrivateNetWork'
  s.version          = '0.1.4'
  s.summary          = 'A short description of YMPodPrivateNetWork.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/gupengling/YMPodPrivateNetWork'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  # s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.license      = {
        :type => "Cpoyright",
        :text => "LICENSE  ©2018 yimifudao.com, Inc. All rights reserved"
    }
  s.author           = { 'gupengling' => 'pengling.gu@1mifudao.com' }
  s.platform     = :ios, "7.0"
  s.source           = { :git => 'https://github.com/gupengling/YMNetWork.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'YMPodPrivateNetWork/Classes/*.{h,m}','YMPodPrivateNetWork/Classes/**/*.{h,m}'
  
  # s.resource_bundles = {
  #   'YMPodPrivateNetWork' => ['YMPodPrivateNetWork/Assets/*.png']
  # }

  s.public_header_files = 'YMPodPrivateNetWork/Classes/*.h'
  #s.public_header_files = 'YMPodPrivateNetWork/Classes/**/*.h'
  s.requires_arc = true
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking'
  s.dependency 'MBProgressHUD'
end
