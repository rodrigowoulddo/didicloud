#
# Be sure to run `pod lib lint didicloud.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'didicloud'
  s.version          = '0.1.14'
  s.summary          = 'An abstraction for CloudKit operations'

  s.swift_versions   = '5.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
didicloud is an abstraction for CloudKit that make CRUD operations easier and less verbose.
                       DESC

  s.homepage         = 'https://github.com/rodrigowoulddo/didicloud'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rodrigofgiglio@gmail.com' => 'rodrigofgiglio@gmail.com' }
  s.source           = { :git => 'https://github.com/rodrigowoulddo/didicloud.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'didicloud/Classes/**/*'
  
  # s.resource_bundles = {
  #   'didicloud' => ['didicloud/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  
  # Dependencies
  s.dependency 'EVReflection/CloudKit', '~> 5.10'
end
