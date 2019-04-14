#
# Be sure to run `pod lib lint SmartPageView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SmartPageView'
  s.version          = '0.2.5'
  s.summary          = 'Simple PageViewController.'
  s.description      = <<-DESC
SmartPageView is Simple PageViewController.
                       DESC

  s.homepage         = 'https://github.com/ShockUtility/SmartPageView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ShockUtility' => 'shock@docs.kr' }
  s.source           = { :git => 'https://github.com/ShockUtility/SmartPageView.git', :tag => s.version.to_s }

  s.swift_version    = '5.0'
  s.ios.deployment_target = '10.0'

  s.source_files = 'SmartPageView/Classes/**/*'
end

# 새로운 버전 생성 후 github.com 에서 릴리스 버전 생성하고 다음의 커맨드로 배포해야된다
# pod trunk push SmartPageView.podspec --verbose --allow-warnings
