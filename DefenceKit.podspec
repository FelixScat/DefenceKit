#
# Be sure to run `pod lib lint DefenceKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DefenceKit'
  s.version          = '0.1.0'
  s.summary          = 'Defence App From Crash'
  s.description      = <<-DESC
  To Defence App From Crash
                       DESC

  s.homepage         = 'https://github.com/FelixScat/DefenceKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Felix' => 'Felix@gmail.com' }
  s.source           = { :git => 'https://github.com/FelixScat/DefenceKit.git', :tag => s.version.to_s }


  s.ios.deployment_target = '8.0'

  s.source_files = 'DefenceKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'DefenceKit' => ['DefenceKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.dependency 'AppSplitKit'
end
